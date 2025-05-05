#!/bin/bash


# This script is used to automatically compile, run and save the results of the benchmark suite.


# Set the path to the benchmarks
BENCHMARKS=(
  "benchmarks/CPU/7zip"
  "benchmarks/CPU/coremark"
  "benchmarks/CPU/coremark-pro"
  "benchmarks/CPU/stockfish"
  "benchmarks/GPU/FFmpeg"
  "benchmarks/GPU/vkmark"
  "benchmarks/IO/fio"
  "benchmarks/IO/iperf3"
  "benchmarks/memory/ramspeed"
  "benchmarks/memory/STREAM"
  "benchmarks/memory/tinymembench"
  "benchmarks/stress-ng"
)

CPU_MHZ=$(awk '/^cpu MHz/ {print $4; exit}' /proc/cpuinfo)
  if [[ -z "$cpu_mhz" ]]; then
    echo "Impossibile rilevare cpu MHz" >&2
    return 1
  fi

RESULTS_FILE="results.txt"

# Setup the environment: update submodules and dependencies
setup(){
    cd benchmarks
    make setup
    cd ..
}

# Clean all benchmarks
clean() {
  cd benchmarks
  make clean
  cd ..
}

# Compile all benchmarks
build() {
  cd benchmarks
  make all
  cd ..
}

# Run all benchmarks
run() {
  cd benchmarks
  make run
  cd ..
}

#Saving the results
results() {
  local name="$1" ips="$2" per_mhz

  if [[ ! -f "$RESULTS_FILE" ]]; then
    {
      echo "CPU MHz: ${CPU_MHZ%.*}"
      echo
      echo "Benchmark           | Iterations/s   | Iter/s per MHz"
      echo "--------------------| -------------- | ---------------"
    } > "$RESULTS_FILE"
  fi

  per_mhz=$(awk -v i="$ips" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')

  printf "%-20s | %12.3f | %15s\n" \
    "$name" "$ips" "$per_mhz" \
    >> "$RESULTS_FILE"

  column -t -s"|" "$RESULTS_FILE" > tmp && mv tmp "$RESULTS_FILE"
}

parse_coremark() {
  local logfile="$1"
  
  local ips
  ips=$(grep -E 'Iterations/Sec' "$logfile" | tail -n1 | awk '{print $NF}')
 
  name=$(basename "$logfile" .log)
 
  results "$name" "$ips"
}
















# The function will be launched automatically when the script is run
main() {
  clean
  setup
  build
  run

  parse_coremark run1.log
  parse_coremark run2.log

  # altri benchmark....
}
main
echo "------------------All benchmarks have been run and the results have been saved to $RESULTS_FILE------------------"
#-------------------------------------------------END----------------------------------------------------