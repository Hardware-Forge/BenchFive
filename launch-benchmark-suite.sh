#!/bin/bash


# This script is used to automatically compile, run and save the results of the benchmark suite.


CPU_MHZ=$(awk '/^cpu MHz/ {print $4; exit}' /proc/cpuinfo)
if [[ -z "$cpu_mhz" ]]; then
  echo "Unable to detect CPU MHz" >&2
  return 1
fi

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

# Display the results
results() {
  local name="$1" ips="$2" per_mhz

  # Print header only once
  if [[ -z "$HEADER_PRINTED" ]]; then
    echo "CPU MHz: ${CPU_MHZ%.*}"
    echo
    echo "Benchmark           | Iterations/s   | Iter/s per MHz"
    echo "--------------------| -------------- | ---------------"
    HEADER_PRINTED=1
  fi

  per_mhz=$(awk -v i="$ips" -v m="$CPU_MHZ" 'BEGIN{printf "%.2f", i/m}')

  printf "%-20s | %12.3f | %15s\n" \
    "$name" "$ips" "$per_mhz"
}

parse_coremark() {
  local results_file="$1"
  
  # Extract only performance run results
  local ips
  ips=$(awk '/Iterations\/Sec/ && /performance run/ {print $NF}' "$results_file")
  if [[ -n "$ips" ]]; then
    results "coremark" "$ips"
  fi
}

# The function will be launched automatically when the script is run
main() {
  clean
  setup
  build
  run

  parse_coremark "results/coremark_results.txt"

  # other benchmarks....
}

main
echo "------------------All benchmarks have been completed------------------"
#-------------------------------------------------END----------------------------------------------------