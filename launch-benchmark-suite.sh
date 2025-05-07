#!/usr/bin/env bash

# This script is used to automatically compile, run and show the results of the benchmark suite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$SCRIPT_DIR/benchmarks"
RESULTS_DIR="$SCRIPT_DIR/results"

# Create results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

HEADER_PRINTED=0 

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
    if command -v lscpu &>/dev/null; then
        lscpu | awk -F':[ \t]+' '/^CPU\(s\)/ {print $2}'
    elif [[ -r /proc/cpuinfo ]]; then
        grep -c "^processor" /proc/cpuinfo
    else
        echo "Unknown"
    fi
}

get_ram_gb() {
    if command -v free &>/dev/null; then
        free -g | awk '/^Mem:/ {print $2}'
    elif [[ -r /proc/meminfo ]]; then
        awk '/^MemTotal:/ {printf "%.0f\n", $2/1024/1024}' /proc/meminfo
    else
        echo "Unknown"
    fi
}

get_cpu_mhz() {
    local freq

      
    if command -v lscpu &>/dev/null; then
        freq=$(lscpu | awk -F':' '
            /^CPU max MHz/ {gsub(/ /,""); print $2; exit}
            /^CPU MHz/     {gsub(/ /,""); print $2; exit}')
        [[ -n $freq ]] && printf "%.0f\n" "$freq" && return 0
    fi

   
    if [[ -r /proc/cpuinfo ]]; then
        freq=$(awk '/^cpu MHz/ {sum+=$4; n++} END{if(n) print sum/n}' /proc/cpuinfo)
        [[ -n $freq ]] && printf "%.0f\n" "$freq" && return 0
    fi

    return 1  
}

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
    local name="$1" ips_sc="$2" ips_mc="$3"

    if [[ $HEADER_PRINTED -eq 0 ]]; then
        echo "CPU MHz: $CPU_MHZ"
        echo
        printf "%-20s | %18s | %22s | %18s | %22s\n" \
               "Benchmark" "Iterations/s" "Iter/s per MHz" "Iterations/s" "Iter/s per MHz"
        printf "%-20s | %18s | %22s | %18s | %22s\n" \
               "" "Single-core" "Single-core" "Multi-core" "Multi-core"
        printf -- "---------------------|--------------------|------------------------|--------------------|------------------------\n"
        HEADER_PRINTED=1
    fi

    local per_mhz_sc per_mhz_mc
    if [[ $ips_sc =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        per_mhz_sc=$(awk -v i="$ips_sc" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')
    else
        per_mhz_sc="---"
    fi
    if [[ $ips_mc =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        per_mhz_mc=$(awk -v i="$ips_mc" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')
    else
        per_mhz_mc="---"
    fi

    printf "%-20s | %18s | %22s | %18s | %22s\n" \
           "$name" "$ips_sc" "$per_mhz_sc" "$ips_mc" "$per_mhz_mc"
}


parse_coremark() {
    local f="$RESULTS_DIR/coremark_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '/^2K performance run parameters/,/^CoreMark 1.0/ {
        if ($1 == "Iterations/Sec") print $3
    }' "$f" |
    while read -r ips_sc; do
        # coremark is only single-core
        result "coremark" "$ips_sc" "---"
    done
}


parse_coremark-pro() {
    local f="$RESULTS_DIR/coremark-pro_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    # Extract the total score
    awk '/^Score:/ {print $2}' "$f" |
    while read -r score; do
        result "coremark-pro" "$score"
    done
}

main() {
    # Title box
    echo "╔══════════════════════════════════════════════╗"
    echo "║         RISC-V Benchmark Suite               ║"
    echo "╚══════════════════════════════════════════════╝"
    echo
    
    CPU_MHZ=$(get_cpu_mhz) || { echo "Unable to detect CPU MHz" >&2; exit 1; }
    (( CPU_MHZ > 0 )) || { echo "Detected CPU MHz is zero, aborting" >&2; exit 1; }
    
    CPU_NAME=$(get_cpu_name)
    CPU_CORES=$(get_cpu_cores)
    RAM_GB=$(get_ram_gb)
    
    # System information box
    echo "┌────────────────────────────────────────────┐"
    echo "│           System Information               │"
    echo "├────────────────────────────────────────────┤"
    printf "│ CPU: %-37s │\n" "$CPU_NAME"
    printf "│ CPU Frequency: %-27s MHz │\n" "$CPU_MHZ"
    printf "│ CPU Cores: %-31s │\n" "$CPU_CORES"
    printf "│ RAM: %-35s GB │\n" "$RAM_GB"
    echo "└────────────────────────────────────────────┘"
    echo

 #   clean
 #   setup
 #   build
 #   run

    parse_coremark 
#   parse_coremark-pro
    # TODO: parse_* per gli altri benchmark…

    echo
    echo "------------------All benchmarks have been completed------------------"
}

main "$@"
