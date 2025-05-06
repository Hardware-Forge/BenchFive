#!/usr/bin/env bash

# This script is used to automatically compile, run and show the results of the benchmark suite.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BENCH_DIR="$SCRIPT_DIR/benchmarks"
RESULTS_DIR="$BENCH_DIR/results"

HEADER_PRINTED=0 


get_cpu_mhz() {
    local freq

    if freq=$(lscpu 2>/dev/null | awk -F':' '/CPU MHz:/ {gsub(/ /,""); print $2; exit}'); then
        [[ -n "$freq" ]] && printf "%.0f\n" "$freq" && return
    fi

    if freq=$(awk '/^cpu MHz/ {sum += $4; n++} END {if (n) print sum/n}' /proc/cpuinfo 2>/dev/null); then
        [[ -n "$freq" ]] && printf "%.0f\n" "$freq" && return
    fi

    if [[ -r /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq ]]; then
        freq=$(< /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
        [[ -n "$freq" ]] && printf "%.0f\n" "$((freq/1000))" && return
    fi

    return 1
}

CPU_MHZ=$(get_cpu_mhz) || { echo "Unable to detect CPU MHz" >&2; exit 1; }

setup(){
  git submodule update --init --recursive; 
  (cd "$BENCH_DIR" && make setup); 
}
clean(){ 
  (cd "$BENCH_DIR" && make clean); 
}
build(){ 
  (cd "$BENCH_DIR" && make all); 
}
run(){ 
  (cd "$BENCH_DIR" && make run); 
}

result() {
    local name="$1" ips="$2"

    if [[ $HEADER_PRINTED -eq 0 ]]; then
        echo "CPU MHz: $CPU_MHZ"
        echo
        printf "%-20s | %12s | %15s\n" "Benchmark" "Iterations/s" "Iter/s per MHz"
        printf -- "--------------------|--------------|---------------\n"
        HEADER_PRINTED=1
    fi

    local per_mhz
    per_mhz=$(awk -v i="$ips" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')
    printf "%-20s | %12.3f | %15s\n" "$name" "$ips" "$per_mhz"
}

parse_coremark() {
    local f="$RESULTS_DIR/coremark_results.txt"
    [[ -r "$f" ]] || { echo "warning: $f not found"; return; }

    awk '/performance run/ && /Iterations\/Sec/ {print $NF}' "$f" |
    while read -r ips; do
        result "coremark" "$ips"
    done
}

# ------------------------------------------------------------------------------
#  Main
# ------------------------------------------------------------------------------
main() {
    clean
    setup
    build
    run

    parse_coremark
    # TODO: parse_* per gli altri benchmark…

    echo "------------------All benchmarks have been completed------------------"
}

main "$@"
