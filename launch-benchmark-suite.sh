#!/usr/bin/env bash

# This script is used to automatically compile, run and show the results of the benchmark suite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$SCRIPT_DIR/benchmarks"
RESULTS_DIR="$SCRIPT_DIR/results"

# Create results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

HEADER_PRINTED=0

#--------------------------Functions for system information:--------------------

get_cpu_name() {
    if command -v lscpu &>/dev/null; then
        lscpu | awk -F':[ \t]+' '/^Model name/ {print $2}'
    elif [[ -r /proc/cpuinfo ]]; then
        awk -F':[ \t]+' '/^model name/ {print $2; exit}' /proc/cpuinfo
    else
        echo "Unknown CPU"
    fi
}

get_cpu_cores() {
    local cores

    if command -v nproc &>/dev/null; then
        cores=$(nproc --all)
    elif command -v lscpu &>/dev/null; then
        cores=$(lscpu | awk -F':[ \t]+' '/^CPU\(s\)/ {print $2}')
    elif [[ -r /proc/cpuinfo ]]; then
        cores=$(grep -c "^processor" /proc/cpuinfo)
    else
        cores="Unknown"
    fi

    cores=${cores//[^0-9]/}

    echo "${cores:-Unknown}"
}


get_ram_gb() {
    if [[ -r /proc/meminfo ]]; then
        local kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
        # kb * 1024 = byte, /1e9 = GB decimali
        printf "%.2f\n" "$(awk -v k="$kb" 'BEGIN{print k*1024/1e9}')"
    else
        echo "Unknown"
    fi
}




get_cpu_mhz() {
    if command -v lscpu &>/dev/null; then
        lscpu | awk -F':[ \t]+' '
            /^CPU max MHz/ { printf("%.0f\n",$2); exit }
            /^CPU MHz/     { printf("%.0f\n",$2); exit }
        '
    elif [[ -r /proc/cpuinfo ]]; then
        awk '/^cpu MHz/ { sum += $4; n++ }
             END {
               if (n) printf("%.0f\n", sum/n)
               else       print "Unknown"
             }' /proc/cpuinfo
    else
        echo "Unknown"
    fi
}


#--------------------------Functions for graphics:------------------------------

COL_W=25 #singlecore
BOX_W=50
COL_WF=25 #multicore

print_table_header() {
    local hdr
    hdr=$(printf "%-25s | %-${COL_W}s | %-${COL_W}s | %-${COL_WF}s | %-${COL_WF}s" \
           "Benchmark" \
           "Single-core score" "Single-core score /MHz" \
           "Multi-core score"  "Multi-core score /MHz")
    
    echo "$hdr"
    
    local len=${#hdr}
    printf '─%.0s' $(seq 1 $len)
    echo
    
    HEADER_PRINTED=1
}



# ─── row() ───
row() {
    # $1 = stringa completa da mettere
    printf "│ %-*s │\n" $((BOX_W-2)) "$1"
}

# ─── row_center() ───
row_center() {
    local text="$1"
    local total=$((BOX_W-2))
    local len=${#text}
    (( len > total )) && { row "$text"; return; }

    local padL=$(( (total - len) / 2 ))
    local padR=$(( total - len - padL ))
    printf "│ %*s%s%*s │\n" \
           "$padL" "" "$text" "$padR" ""
}

# ─── center() ───
center() {
    local width=$1
    local text="$2"
    local len=${#text}
    # se il testo è più lungo, lo restituiamo inalterato
    (( len >= width )) && { printf "%s" "$text"; return; }

    local padL=$(( (width - len) / 2 ))
    local padR=$(( width - len - padL ))
    printf "%*s%s%*s" \
           "$padL" "" "$text" "$padR" ""
}

#-------------------Functions to launch the benchmark suite-----------------

setup(){
  (make setup); 
}
clean(){ 
  (make clean); 
}
build(){ 
  (make all); 
}
run(){ 
  (make run); 
}


result() {
    local name="$1" sc="$2" mc="$3" pl="$4"

    
    local unit
    case "$name" in
        coremark|coremark-pro)                 unit="Iteration/s" ;;
        7zip-compressing|7zip-decompressing)   unit="MIPS"        ;;
        stockfish)                             unit="Nodes/s"     ;;
        *)                                     unit=""            ;;
    esac

    if [[ "$name" =~ ^ffmpeg || "$name" =~ ^fio || "$name" =~ ^iperf || "$name" =~ ^stream || "$name" =~ ^tiny || "$name" =~ ^stressng_temp ]]; then
        printf "%-25s | %-${COL_W}s | %-${COL_W}s | %-${COL_WF}s | %-${COL_WF}s\n" \
               "$name" "$sc $mc $pl" "----" "----" "----"
        return
    fi
    if [[ "$name" =~ ^stressng_vm ]]; then
        printf "%-30s | %-25s\n" "$name" "$sc $mc $pl"
        return
    fi

    local per_sc="---" per_mc="---"
    if [[ $sc =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        per_sc=$(awk -v v="$sc" -v mhz="$CPU_MHZ" 'BEGIN{printf "%.2f", v/mhz}')
        sc="${sc} ${unit}"
    else
        sc="${sc:----}"
    fi
    if [[ $mc =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        per_mc=$(awk -v v="$mc" -v mhz="$CPU_MHZ" 'BEGIN{printf "%.2f", v/mhz}')
        mc="${mc} ${unit}"
    else
        mc="${mc:----}"
    fi

    printf "%-25s | %-${COL_W}s | %-${COL_W}s | %-${COL_WF}s | %-${COL_WF}s\n" \
           "$name" "$sc" "$per_sc" "$mc" "$per_mc"
}



 parse_coremark() {
     local f="$RESULTS_DIR/coremark_results.txt"
     [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '/^2K performance run parameters/,/^CoreMark 1.0/ {
        if ($1 == "Iterations/Sec") printf "%.2f\n", $3
    }' "$f" |
     while read -r ips; do
         result "coremark" "$ips" "" ""
     done
 }


parse_coremark-pro() {
    local f="$RESULTS_DIR/coremark-pro_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '$1 == "CoreMark-PRO" {
        mc = $2
        sc = $3
        print sc, mc
    }' "$f" |
    while read -r sc mc; do
        result "coremark-pro" "$sc" "$mc" ""
    done
}

parse_7zip() {
    local f="$RESULTS_DIR/7zip_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '/^Avr:/ {
        comp = $2        
        decomp = $7        
        print comp, decomp
    }' "$f" |
    while read -r comp decomp; do
        result "7zip-compressing" ""      "$comp" ""
        result "7zip-decompressing" ""      "$decomp" ""
    done
}


parse_stockfish() {
    local f="$RESULTS_DIR/stockfish_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk -F: '/Nodes\/second/ {
        gsub(/^[ \t]+|[ \t]+$/, "", $2)
        print $2
    }' "$f" | 
    while read -r nodes_per_sec; do
        result "stockfish" "$nodes_per_sec" "" ""
    done
}

get_geekbench_results() {
    local txt="$RESULTS_DIR/geekbench_results.txt"
    local out="$RESULTS_DIR/geekbench_results.html"
    [[ -r $txt ]] || return
    local url
    url=$(grep -oE 'https://browser\.geekbench\.com/v6/cpu/[0-9]+' "$txt" | head -n1)
    [[ -n $url ]] || return
    mkdir -p "$RESULTS_DIR"
    curl -sL "$url" -o "$out" || return
}


parse_geekbench() {
    local html="$RESULTS_DIR/geekbench_results.html"
    [[ -r $html ]] || { echo "warning: $html not found"; return; }

    # ─── SINGLE-CORE ──────────────────────────────────────────────
    sc=$(grep -A1 "<div class='score-container score-container-1" "$html" \
          | grep -oP '(?<=<div class=.score.>)[0-9,]+' \
          | head -n1)

    # ─── MULTI-CORE ───────────────────────────────────────────────
    local mc
    mc=$(grep -A1 "<div class='score-container desktop'>" "$html" \
          | grep -oP '(?<=<div class=.score.>)[0-9,]+' \
          | head -n1)

    sc=${sc//,/}
    mc=${mc//,/}

    [[ -n $sc && -n $mc ]] || { echo "warning: Geekbench scores not found"; return; }

    result "geekbench" "$sc" "$mc" ""
}
parse_ffmpeg() {
    local f="$RESULTS_DIR/ffmpeg_codifica.txt"
    local f2="$RESULTS_DIR/ffmpeg_decodifica.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }
    [[ -r "$f2" ]] || { echo "warning: $f2 not found"; return; }

    # ─── CODIFICA ───────────────────────────────────────────────
    read time fps < <(
    awk '/encoded/ {
        match($0, /in ([0-9.]+)s \(([0-9.]+) fps\)/, a)
        print a[1], a[2]
    }' $f 
    )
    result "ffmpeg_encode_time" "$time" "s" "" ""
    result "ffmpeg_encode_fps" "$fps" "fps" "" ""


    # ─── DECODIFICA ───────────────────────────────────────────────
    read time speed < <(
    awk '/frame=/{t=$0} END{
        match(t, /time=([0-9:.]+)/, a)
        match(t, /speed=([0-9.]+)x/, b)

        # Converti "00:00:28.23" in secondi
        split(a[1], parts, ":")
        seconds = parts[1]*3600 + parts[2]*60 + parts[3]
        
        print seconds, b[1]
    }' "$f2"
    )
    result "ffmpeg_decode_time" "$time" "s" "" ""
    result "ffmpeg_decode_speed" "$speed" "x" "" ""
}

parse_fio() {
    local f="$RESULTS_DIR/fio_resultscmd.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    read bwr bww iopsr iopsw latr latw < <(
        awk '
        BEGIN {
            section=""
            read_lat_done=write_lat_done=0
        }
        /^  read:/ {
            section="read"
            if (match($0, /BW=[^(]+\(([0-9.]+)MB\/s\)/, a)) bwr = a[1]
            if (match($0, /IOPS=([^,]+)/,      c)) iopsr = c[1]
            next
        }
        /^  write:/ {
            section="write"
            if (match($0, /BW=[^(]+\(([0-9.]+)MB\/s\)/, a)) bww = a[1]
            if (match($0, /IOPS=([^,;]+)/,      c)) iopsw = c[1]
            next
        }
        /^[[:space:]]+lat \(usec\):.*avg=/ {
            if (section=="read" && !read_lat_done) {
                if (match($0, /avg=([0-9.]+)/, d)) {
                    latr = d[1]
                    read_lat_done = 1
                }
            }
            else if (section=="write" && !write_lat_done) {
                if (match($0, /avg=([0-9.]+)/, d)) {
                    latw = d[1]
                    write_lat_done = 1
                }
            }
            next
        }
        END {
            print bwr, bww, iopsr, iopsw, latr, latw
        }
        ' "$f"
    )

    result "fio_bandwidth_r" "$bwr" "MB/s" "" 
    result "fio_bandwidth_w" "$bww" "MB/s" "" 
    result "fio_iops_r" "$iopsr" "IOPS" "" 
    result "fio_iops_w" "$iopsw" "IOPS" "" 
    result "fio_lat_r" "$latr" "us" "" 
    result "fio_lat_w" "$latw" "us" "" 
}

parse_iperf3() {
    local f="$RESULTS_DIR/iperf3_results.txt"

    # ─── NET THROUGHPUT (ultimo valore Gbits/sec) ────────────────
    local throughput
    throughput=$(awk '
        /Gbits\/sec/ { last=$0 }
        END {
            if (match(last, /([0-9.]+)[[:space:]]*Gbits\/sec/, a))
                printf("%.1f\n", a[1])
        }' "$f"
    )

    result "iperf_net_throughput" "$throughput" "Gb/s" "" 
}
parse_stream() {
    local f="$RESULTS_DIR/stream_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    # ─── STREAM benchmark (Scale & Triad + avg error) ────────
    read scale_rate scale_avg triad_rate triad_avg avg_error < <(
        awk '
            /^Scale:/ {
                scale_rate = $2
                scale_avg  = $3
            }
            /^Triad:/ {
                triad_rate = $2
                triad_avg  = $3
            }
            /^Solution Validates:/ {
                # Line e.g.: Solution Validates: avg error less than 1.000000e-13 on all three arrays
                # $6 contiene il valore scientifico
                avg_error = $6
            }
            END {
                print scale_rate, scale_avg, triad_rate, triad_avg, avg_error
            }
        ' "$f"
    )

    result "stream_scale_rate&lat" "${scale_rate:-N/A}"    "MB/s"  " ${scale_avg:-N/A} s"
    result "stream_triad_rate&lat" "${triad_rate:-N/A}"    "MB/s"  " ${triad_avg:-N/A} s"
    result "stream_avg_error"       "${avg_error:-N/A}"    "avgerror"      ""
}


parse_tinymembench() {
    local f="$RESULTS_DIR/tinymembench_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f non trovato o non leggibile"; return; }

    # Estrai il valore numerico subito prima di "MB/s"
    local copy_rate fill_rate
    copy_rate=$(awk '/^[[:space:]]*C[[:space:]]+copy/ {print $(NF-1); exit}' "$f")
    fill_rate=$(awk '/^[[:space:]]*C[[:space:]]+fill/ {print $(NF-1); exit}' "$f")

    copy_rate=${copy_rate:-N/A}
    fill_rate=${fill_rate:-N/A}

    result "tinymemb_copy" "$copy_rate" "MB/s" ""
    result "tinymemb_fill" "$fill_rate" "MB/s" ""
}



parse_tinymembench_latency() {
    local f="$RESULTS_DIR/tinymembench_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f non trovato o non leggibile"; return; }

    # Controlla se le informazioni di latenza sono presenti nel file
    if ! grep -q "^block size" "$f"; then
        echo
        echo "Memory latency table not available in tinymembench results"
        return
    fi

    # Riga vuota e titolo
    echo
    echo "memory latency from cache L1 to ram - Single Random Read"
    # Intestazione tabella
    echo "Block size | Single random read (ns)"
    echo "-----------|---------------------------"

    awk '
    /^block size/ { in_table=1; next }
    in_table && /^$/  { exit }
    in_table && /^[[:space:]]*[0-9]+/ {
        printf "%9s  | %21s\n", $1, $3
    }
    ' "$f"
}
parse_stressng_temp() {
    local f="$RESULTS_DIR/stress-ng_cputemp.txt"
    [[ -r "$f" ]] || { echo "warning: $f non trovato o non leggibile"; return; }
    local temp
    read temp < <(
        awk '
        /cluster0_thermal/ {
            if (match($0, /([0-9]+\.[0-9]+)[[:space:]]*C/, a))
                print a[1]
        }
        ' "$f"
    )


    result "stressng_temp" "$temp" "C" ""
}
parse_stressng_vm() {
    local f="$RESULTS_DIR/stress-ng_vm.txt"
    [[ -r "$f" ]] || { echo "warning: $f non trovato o non leggibile"; return; }

    local bogo_ops
    read bogo_ops < <(
        awk '
        /metrc:.*vm/ {
            print $5
            exit
        }
        ' "$f"
    )

    result "stressng_vm" "$bogo_ops" "bogo-ops" ""
}
print_obpmark_results() {
    local f="$RESULTS_DIR/obpmark_results.txt"
    if [[ -r "$f" ]]; then
        awk '
        # Rilevo il nome del test
        /^============ OBPMark/ {
          raw = substr($0, match($0, /OBPMark/))
          header = "Test: " raw
          fill_len = 65 - length(header)
          for (i = 0; i < fill_len; i++) header = header "="
          test_name = header
        }

        # Inizio raccolta metriche
        /^Benchmark metrics:/ {
          in_metrics = 1
          next
        }

        # Fine sezione metriche: stampo blocco
        in_metrics && NF == 0 {
          print test_name
          printf "  %s\n", elapsed
          printf "  %s\n", total
          printf "  %s\n\n", throughput
          in_metrics = 0
          elapsed = total = throughput = ""
          next
        }

        # Cattura valori metriche
        in_metrics {
          if ($0 ~ /Elapsed time execution/) {
            sub(/.*= */, "", $0)
            elapsed = sprintf("%-26s = %s", "Elapsed time execution", $0)
          } else if ($0 ~ /Total execution time/) {
            sub(/.*= */, "", $0)
            total = sprintf("%-26s = %s", "Total execution time", $0)
          } else if ($0 ~ /Throughput/) {
            sub(/.*= */, "", $0)
            throughput = sprintf("%-26s = %s", "Throughput", $0)
          }
        }
        ' "$f"
        echo "──────────────────────────────────────────────────────────"
    else
        echo "File obpmark_results.txt not found in $RESULTS_DIR"
    fi
}


print_organized_results() {
    # ─────────────────────────── CPU ──────────────────────────────────────────────────────────────────────────────────────────────────────────────
    echo "CPU"
    echo "─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────"
    print_table_header
    parse_coremark
    parse_coremark-pro
    parse_7zip
    parse_stockfish
    get_geekbench_results
    parse_geekbench
    parse_stressng_temp
    echo

    # ─────────────────────────── RAM ──────────────────────────────
    echo "RAM"
    echo "──────────────────────────────────────────────────────────"
    printf "%-30s | %-25s\n" "Benchmark" "Score"
    printf "%-30s-+-%-25s\n" "$(printf '%.0s─' {1..30})" "$(printf '%.0s─' {1..25})"
    parse_stressng_vm
    if [[ -r "$RESULTS_DIR/stream_results.txt" ]]; then
        awk '
            BEGIN { OFS=" | " }
            /^[[:space:]]*Scale:/ {
                printf "%-30s | %-25s\n", "stream_scale_rate&lat", $2 " MB/s " $3 " s"
            }
            /^[[:space:]]*Triad:/ {
                printf "%-30s | %-25s\n", "stream_triad_rate&lat", $2 " MB/s " $3 " s"
            }
            /Solution Validates:/ {
                if (match($0, /less than ([0-9.eE+-]+)/, a)) {
                    printf "%-30s | %-25s\n", "stream_avg_error", a[1]
                }
            }
        ' "$RESULTS_DIR/stream_results.txt"
    else
        printf "%-30s | %-25s\n" "stream_benchmark" "File not found"
    fi

        # -------- TINYMEMBENCH ----
    if [[ -r "$RESULTS_DIR/tinymembench_results.txt" ]]; then
        # --- copy ---
        copy_rate=$(awk '
            /^[[:space:]]*C[[:space:]]+copy/ {
                if (match($0, /[0-9]+(\.[0-9]+)?[[:space:]]*MB\/s/)) {
                    val = substr($0, RSTART, RLENGTH)
                    sub(/[[:space:]]*MB\/s/, "", val)   # rimuovi l’unità
                    print val
                    exit
                }
            }' "$RESULTS_DIR/tinymembench_results.txt")

        # --- fill ---
        fill_rate=$(awk '
            /^[[:space:]]*C[[:space:]]+fill/ {
                if (match($0, /[0-9]+(\.[0-9]+)?[[:space:]]*MB\/s/)) {
                    val = substr($0, RSTART, RLENGTH)
                    sub(/[[:space:]]*MB\/s/, "", val)
                    print val
                    exit
                }
            }' "$RESULTS_DIR/tinymembench_results.txt")

        copy_rate=${copy_rate:-N/A}
        fill_rate=${fill_rate:-N/A}

        printf "%-30s | %-25s\n" "tinymemb_copy" "${copy_rate} MB/s"
        printf "%-30s | %-25s\n" "tinymemb_fill" "${fill_rate} MB/s"
    else
        printf "%-30s | %-25s\n" "tinymembench" "File not found"
    fi


    echo

    # ----- LATENCY TABLE -------
    [[ -r "$RESULTS_DIR/tinymembench_results.txt" ]] && parse_tinymembench_latency

    ## ──────────────────────────  I/O  ───────────────────────────
    echo
    echo "I/O"
    echo "──────────────────────────────────────────────────────────"
    printf "%-30s | %-25s\n" "Benchmark" "Score"
    printf "%-30s-+-%-25s\n" "$(printf '%.0s─' {1..30})" "$(printf '%.0s─' {1..25})"

    # ---------- FIO ------------------------------------------------
    if [[ -r "$RESULTS_DIR/fio_resultscmd.txt" ]]; then
        fiof="$RESULTS_DIR/fio_resultscmd.txt"

        # ── helper: KiB→MB, GiB→MB, ecc. ──────────────────────────
        convert_bw_to_mb() {
            local tok="$1" num unit mb
            num=$(echo "$tok" | sed -nE 's/([0-9.]+).*/\1/p')
            unit=$(echo "$tok" | sed -nE 's/[0-9.]+([A-Za-z]+)\/s.*/\1/p')
            case "$unit" in
                KiB|kB) mb=$(awk -v n="$num" 'BEGIN{printf "%.2f", n/1024}') ;;
                KB)     mb=$(awk -v n="$num" 'BEGIN{printf "%.2f", n/1000}') ;;
                MiB|MB) mb="$num" ;;
                GiB|GB) mb=$(awk -v n="$num" 'BEGIN{printf "%.2f", n*1024}') ;;
                *)      mb="$num" ;;
            esac
            echo "$mb"
        }

        # ── helper: nsec/usec/msec → µs ───────────────────────────
        to_us() {
            local val="$1" unit="$2"
            case "$unit" in
                nsec) awk -v v="$val" 'BEGIN{printf "%.2f", v/1000}' ;;
                msec) awk -v v="$val" 'BEGIN{printf "%.2f", v*1000}' ;;
                *)    printf "%.2f" "$val" ;;
            esac
        }

        # prima riga "read:" e "write:"
        read_line=$(grep -m1 '^[[:space:]]*read:'  "$fiof")
        write_line=$(grep -m1 '^[[:space:]]*write:' "$fiof")

        # IOPS
        read_iops=$(echo "$read_line"  | sed -nE 's/.*IOPS=([0-9.]+).*/\1/p')
        write_iops=$(echo "$write_line" | sed -nE 's/.*IOPS=([0-9.]+).*/\1/p')

        # Bandwidth
        bw_read_tok=$(echo "$read_line"  | sed -nE 's/.*BW=([^,]+).*/\1/p')
        bw_write_tok=$(echo "$write_line" | sed -nE 's/.*BW=([^,]+).*/\1/p')
        bwr=$(convert_bw_to_mb "$bw_read_tok")
        bww=$(convert_bw_to_mb "$bw_write_tok")

        # Latency: primi due match della forma "lat (xsec): ... avg=..."
        mapfile -t lat_lines < <(grep -n '^[[:space:]]*lat (' "$fiof" | head -n2)
        latr="N/A"; latw="N/A"
        if [[ ${lat_lines[0]} ]]; then
            line=$(sed -n "${lat_lines[0]%%:*}p" "$fiof")
            avg=$(echo "$line" | sed -nE 's/.*avg=([0-9.]+).*/\1/p')
            unit=$(echo "$line" | sed -nE 's/.*lat \(([a-z]+)\).*/\1/p')
            latr=$(to_us "$avg" "$unit")
        fi
        if [[ ${lat_lines[1]} ]]; then
            line=$(sed -n "${lat_lines[1]%%:*}p" "$fiof")
            avg=$(echo "$line" | sed -nE 's/.*avg=([0-9.]+).*/\1/p')
            unit=$(echo "$line" | sed -nE 's/.*lat \(([a-z]+)\).*/\1/p')
            latw=$(to_us "$avg" "$unit")
        fi

        printf "%-30s | %-25s\n" "fio_bandwidth_r" "${bwr:-N/A} MB/s"
        printf "%-30s | %-25s\n" "fio_bandwidth_w" "${bww:-N/A} MB/s"
        printf "%-30s | %-25s\n" "fio_iops_r"      "${read_iops:-N/A} IOPS"
        printf "%-30s | %-25s\n" "fio_iops_w"      "${write_iops:-N/A} IOPS"
        printf "%-30s | %-25s\n" "fio_lat_r"       "${latr:-N/A} µs"
        printf "%-30s | %-25s\n" "fio_lat_w"       "${latw:-N/A} µs"
    else
        printf "%-30s | %-25s\n" "fio" "File not found"
    fi

    # ---------- IPERF3 --------------------------------------------
    if [[ -r "$RESULTS_DIR/iperf3_results.txt" ]]; then
        last=$(grep -E 'bits/sec' "$RESULTS_DIR/iperf3_results.txt" | tail -n1)
        if [[ $last =~ ([0-9.]+)[[:space:]]*Gbits/sec ]]; then
            thr=${BASH_REMATCH[1]}
        elif [[ $last =~ ([0-9.]+)[[:space:]]*Mbits/sec ]]; then
            thr=$(awk -v v="${BASH_REMATCH[1]}" 'BEGIN{printf "%.2f", v/1000}')
        else
            thr="N/A"
        fi
        printf "%-30s | %-25s\n" "iperf_net_throughput" "${thr} Gb/s"
    else
        printf "%-30s | %-25s\n" "iperf3" "File not found"
    fi
    echo

    ## ──────────────────────────  GPU  ───────────────────────────
    echo "GPU"
    echo "──────────────────────────────────────────────────────────"
    printf "%-30s | %-25s\n" "Benchmark" "Score"
    printf "%-30s-+-%-25s\n" "$(printf '%.0s─' {1..30})" "$(printf '%.0s─' {1..25})"

        # ---------- FFMPEG --------------------------------------------
    if [[ -r "$RESULTS_DIR/ffmpeg_codifica.txt" && -r "$RESULTS_DIR/ffmpeg_decodifica.txt" ]]; then
        # ── Codifica ────────────────────────────────────────────
        enc_line=$(grep -m1 'encoded' "$RESULTS_DIR/ffmpeg_codifica.txt")

        # tempo in secondi
        enc_time=$(echo "$enc_line" | sed -nE 's/.*in ([0-9.]+)s .*/\1/p')
        # fps
        enc_fps=$(echo  "$enc_line" | sed -nE 's/.*\(([0-9.]+) fps\).*/\1/p')

        # ── Decodifica ──────────────────────────────────────────
        dec_line=$(grep 'frame=' "$RESULTS_DIR/ffmpeg_decodifica.txt" | tail -n1)

        # tempo in secondi
        if [[ $dec_line =~ time=([0-9:.]+) ]]; then
            IFS=':.' read -r h m s ms <<< "${BASH_REMATCH[1]}"
            dec_time=$(awk -v h="$h" -v m="$m" -v s="$s" 'BEGIN{printf "%.2f", h*3600+m*60+s}')
        else
            dec_time="N/A"
        fi

        # speed in x
        dec_speed=$(echo "$dec_line" | sed -nE 's/.*speed=[[:space:]]*([0-9.]+)x.*/\1/p')


        printf "%-30s | %-25s\n" "ffmpeg_encode_time"  "${enc_time:-N/A} s"
        printf "%-30s | %-25s\n" "ffmpeg_encode_fps"   "${enc_fps:-N/A} fps"
        printf "%-30s | %-25s\n" "ffmpeg_decode_time"  "${dec_time:-N/A} s"
        printf "%-30s | %-25s\n" "ffmpeg_decode_speed" "${dec_speed:-N/A} x"
    else
        printf "%-30s | %-25s\n" "ffmpeg" "File not found"
    fi

    echo

    echo "ai-obpmark"
    echo "──────────────────────────────────────────────────────────"
    print_obpmark_results
    echo

}


main() {
    clear
    #setup
    #build
    #run
    clear

    # Title box
    echo "╔══════════════════════════════════════════════════╗"
    echo "║              RISC-V Benchmark Suite              ║"
    echo "╚══════════════════════════════════════════════════╝"
    
    if ! CPU_MHZ=$(get_cpu_mhz 2>/dev/null); then
    echo "Unable to detect CPU MHz, default set to 1" >&2
    CPU_MHZ=1
    fi
    CPU_NAME=$(get_cpu_name) || { echo "Unable to detect CPU name" >&2; exit 1; }
    CPU_CORES=$(get_cpu_cores) || { echo "Unable to detect CPU cores" >&2; exit 1; }
    RAM_GB=$(get_ram_gb) || { echo "Unable to detect RAM GB" >&2; exit 1; }
    
    # System information box
    echo "┌$(printf '─%.0s' $(seq 1 $BOX_W))┐"
    row_center "System Information"
    echo "├$(printf '─%.0s' $(seq 1 $BOX_W))┤"
    row "CPU name: $CPU_NAME"
    row "CPU frequency: ${CPU_MHZ} MHz"
    row "CPU cores: $CPU_CORES"
    row "RAM: ${RAM_GB} GB"
    echo "└$(printf '─%.0s' $(seq 1 $BOX_W))┘"
    echo

    # Print organized benchmark results
    print_organized_results
    
    echo
    echo "------------------------------------------------------All benchmarks have been completed----------------------------------------------------"
}

main "$@"