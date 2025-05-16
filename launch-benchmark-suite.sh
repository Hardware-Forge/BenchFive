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

    if [[ "$name" =~ ^ffmpeg || "$name" =~ ^fio || "$name" =~ ^iperf || "$name" =~ ^stream || "$name" =~ ^tiny || "$name" =~ ^stress ]]; then
        printf "%-25s | %-${COL_W}s | %-${COL_W}s | %-${COL_WF}s | %-${COL_WF}s\n" \
               "$name" "$sc $mc $pl" "----" "----" "----"
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
    url=$(grep -m1 -oE 'https://browser\.geekbench\.com/[A-Za-z0-9/_-]+' "$txt")
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

    # ─── STREAM benchmark (Scale & Triad) ──────────────────────
    read scale_rate scale_avg triad_rate triad_avg < <(
        awk '
            /^Scale:/ {
                # Format in file: Scale:           17720.9     0.001245     0.000903     0.001738
                # $2 = Best Rate MB/s, $3 = Avg time (s)
                scale_rate = $2
                scale_avg  = $3
            }
            /^Triad:/ {
                # Format in file: Triad:          19497.1     0.001834     0.001231     0.002897
                # $2 = Best Rate MB/s, $3 = Avg time (s)
                triad_rate = $2
                triad_avg  = $3
            }
            END {
                print scale_rate, scale_avg, triad_rate, triad_avg
            }
        ' "$f"
    )
    result "stream_scale_rate&lat" "${scale_rate:-N/A}" "MB/s" " ${scale_avg:-N/A} s"
    result "stream_triad_rate&lat" "${triad_rate:-N/A}" "MB/s" " ${triad_avg:-N/A} s"
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

    result "stressng_vm_bogo_ops" "$bogo_ops" "bogo-ops" ""
}

print_organized_results() {
    # ─────────────────────────── CPU ────────────────────────────
    echo "CPU"
    echo "───────────────────────────────────────────────────"
    print_table_header
    parse_coremark
    parse_coremark-pro
    parse_7zip
    parse_stockfish
    get_geekbench_results
    parse_geekbench
    echo

    # ─────────────────────────── RAM ────────────────────────────
    echo "RAM"
    echo "───────────────────────────────────────────────────"
    printf "%-30s | %-25s\n" "Benchmark" "Score"
    printf "%-30s-+-%-25s\n" "$(printf '%.0s─' {1..30})" "$(printf '%.0s─' {1..25})"

    # -------- STREAM ----------
    if [[ -r "$RESULTS_DIR/stream_results.txt" ]]; then
        awk '
            BEGIN { OFS=" | " }
            /^Scale:/ {
                printf "%-30s | %-25s\n",
                       "stream_scale_rate&lat",  $2 " MB/s " $3 "s"
            }
            /^Triad:/ {
                printf "%-30s | %-25s\n",
                       "stream_triad_rate&lat", $2 " MB/s " $3 "s"
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
                    sub(/[[:space:]]*MB\/s/, "", val)   # rimuovi l'unità
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

    # ─────────────────────────── I/O ────────────────────────────
    echo
    echo "I/O"
    echo "───────────────────────────────────────────────────"
    printf "%-30s | %-25s\n" "Benchmark" "Score"
    printf "%-30s-+-%-25s\n" "$(printf '%.0s─' {1..30})" "$(printf '%.0s─' {1..25})"

    # -------- FIO ----------
    if [[ -r "$RESULTS_DIR/fio_resultscmd.txt" ]]; then
        local bwr bww iopsr iopsw latr latw
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
            ' "$RESULTS_DIR/fio_resultscmd.txt"
        )

        printf "%-30s | %-25s\n" "fio_bandwidth_r" "${bwr:-N/A} MB/s"
        printf "%-30s | %-25s\n" "fio_bandwidth_w" "${bww:-N/A} MB/s"
        printf "%-30s | %-25s\n" "fio_iops_r" "${iopsr:-N/A} IOPS"
        printf "%-30s | %-25s\n" "fio_iops_w" "${iopsw:-N/A} IOPS"
        printf "%-30s | %-25s\n" "fio_lat_r" "${latr:-N/A} us"
        printf "%-30s | %-25s\n" "fio_lat_w" "${latw:-N/A} us"
    else
        printf "%-30s | %-25s\n" "fio_benchmark" "File not found"
    fi

    echo

    [[ -r "$RESULTS_DIR/ffmpeg_codifica.txt"      && -r "$RESULTS_DIR/ffmpeg_decodifica.txt" ]] && parse_ffmpeg  >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/fio_resultscmd.txt"   ]] && parse_fio         >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/iperf3_results.txt"  ]] && parse_iperf3      >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/stream_results.txt"  ]] && parse_stream      >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/tinymembench_results.txt" ]] && parse_tinymembench >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/stress-ng_vm.txt"    ]] && parse_stressng_vm >/dev/null 2>&1
    [[ -r "$RESULTS_DIR/stress-ng_cputemp.txt" ]] && parse_stressng_temp >/dev/null 2>&1
}


main() {
    #setup
    #build
    #run
    clear

    # Title box
    echo "╔══════════════════════════════════════════════════╗"
    echo "║              RISC-V Benchmark Suite              ║"
    echo "╚══════════════════════════════════════════════════╝"
    
    CPU_MHZ=$(get_cpu_mhz) || { echo "Unable to detect CPU MHz" >&2; exit 1; }
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