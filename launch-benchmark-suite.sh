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
        echo $(( kb / 1024 / 1024 ))
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

COL_W=28
BOX_W=44

print_table_header() {
    # intestazione
    printf "%-20s │ %-${COL_W}s │ %-${COL_W}s │ %-${COL_W}s │ %-${COL_W}s\n" \
           "Benchmark" "Single-core score" "Single-core /MHz" \
           "Multi-core score"  "Multi-core /MHz"
    local total_w=$((20 + 4*COL_W + 4*3))

    printf '─%.0s' $(seq 1 "$total_w")
    printf '\n'
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
  git submodule update --init --recursive; 
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
        result "7zip-decompressing" ""      "$comp"
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

 #   clean
 #   setup
 #   build
 #   run
 
    print_table_header
    parse_coremark 
    parse_coremark-pro
    parse_7zip
    parse_stockfish
    # TODO: parse_* per gli altri benchmark…

    echo
    echo "--------------------------------------------------------All benchmarks have been completed-------------------------------------------------------"
}

main "$@"