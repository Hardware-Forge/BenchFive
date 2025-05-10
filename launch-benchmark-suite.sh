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

COL_W=27
BOX_W=44

print_table_header() {
    local hdr
    hdr=$(printf "%-20s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s" \
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
    local name="$1" sc="$2" mc="$3"

    
    local unit
    case "$name" in
        coremark|coremark-pro)                 unit="Iteration/s" ;;
        7zip-compressing|7zip-decompressing)   unit="MIPS"        ;;
        stockfish)                             unit="Nodes/s"     ;;
        *)                                     unit=""            ;;
    esac

    if [[ "$name" =~ ^ffmpeg || "$name" =~ ^fio || "$name" =~ ^iperf ]]; then
        printf "%-20s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s\n" \
               "$name" "$sc$mc" "----" "----" "----"
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

    printf "%-20s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s | %-${COL_W}s\n" \
           "$name" "$sc" "$per_sc" "$mc" "$per_mc"
}



parse_coremark() {
    local f="$RESULTS_DIR/coremark_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '/^2K performance run parameters/,/^CoreMark 1.0/ {
        if ($1 == "Iterations/Sec") print $3
    }' "$f" |
    while read -r ips; do
        result "coremark" "$ips" ""
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
        result "coremark-pro" "$sc" "$mc"
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
        result "7zip-compressing" ""      "$comp"
        result "7zip-decompressing" ""      "$decomp"
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
        result "stockfish" "$nodes_per_sec" ""
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

    result "geekbench" "$sc" "$mc"
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
    result "ffmpeg_encode_time" "$time" "s" ""
    result "ffmpeg_encode_fps" "$fps" "fps" ""


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
    result "ffmpeg_decode_time" "$time" "s" ""
    result "ffmpeg_decode_speed" "$speed" "x" ""
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
        # Catturo BW e IOPS di read
        /^  read:/ {
            section="read"
            if (match($0, /BW=[^(]+\(([0-9.]+)MB\/s\)/, a)) bwr = a[1]
            if (match($0, /IOPS=([^,]+)/,      c)) iopsr = c[1]
            next
        }
        # Catturo BW e IOPS di write
        /^  write:/ {
            section="write"
            if (match($0, /BW=[^(]+\(([0-9.]+)MB\/s\)/, a)) bww = a[1]
            if (match($0, /IOPS=([^,;]+)/,      c)) iopsw = c[1]
            next
        }
        # Catturo lat (usec): avg=... in base alla sezione corrente
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
            # Se qualche valore è rimasto vuoto, lo lasciamo comunque stampato (""), 
            # così result non va in errore di arità
            print bwr, bww, iopsr, iopsw, latr, latw
        }
        ' "$f"
    )

    result "fio_bandwidth_r" "$bwr" "MB/s" ""
    result "fio_bandwidth_w" "$bww" "MB/s" ""
    result "fio_iops_r" "$iopsr" "IOPS" ""
    result "fio_iops_w" "$iopsw" "IOPS" ""
    result "fio_lat_r" "$latr" "usec" ""
    result "fio_lat_w" "$latw" "usec" ""
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





main() {
    clear
    # Title box
    echo "╔════════════════════════════════════════════╗"
    echo "║          RISC-V Benchmark Suite            ║"
    echo "╚════════════════════════════════════════════╝"
    echo
    
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


    # setup
    # build
    # run
 
     print_table_header
    # parse_coremark 
    # parse_coremark-pro
    # parse_7zip
    # parse_stockfish
    # get_geekbench_results
    # parse_geekbench
    parse_ffmpeg
    parse_fio
    parse_iperf3
    # TODO: parse_* per gli altri benchmark…

    echo
    echo "------------------------------------------------------All benchmarks have been completed----------------------------------------------------"
}

main "$@"