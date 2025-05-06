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
    local name="$1" ips="$2"

    if [[ $HEADER_PRINTED -eq 0 ]]; then
        echo "CPU MHz: $CPU_MHZ"
        echo
        printf "%-20s | %12s | %15s\n" "Benchmark" "Iterations/s" "Iter/s per MHz"
        printf -- "---------------------|--------------|---------------\n"
        HEADER_PRINTED=1
    fi

    local per_mhz
    per_mhz=$(awk -v i="$ips" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')
    printf "%-20s | %12.3f | %15s\n" "$name" "$ips" "$per_mhz"
}

parse_coremark() {
    local f="$RESULTS_DIR/coremark_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    # Extract the performance run result (first run)
    awk '/^2K performance run parameters/,/^CoreMark 1.0/ {
        if ($1 == "Iterations/Sec") {
            print $3
        }
    }' "$f" |
    while read -r ips; do
        result "coremark" "$ips"
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
    parse_coremark-pro
    # TODO: parse_* per gli altri benchmark…

    echo
    echo "------------------All benchmarks have been completed------------------"
}

main "$@"
