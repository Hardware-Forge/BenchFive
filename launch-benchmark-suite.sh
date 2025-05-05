#!/usr/bin/env bash

# This script automatically compiles, runs and saves all benchmark results.

# List of benchmark dirs (unused by CoreMark parser, 
# but useful per build/run if in futuro lo sfrutti)
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

# detect CPU MHz once
CPU_MHZ=$(awk '/^cpu MHz/ {print int($4); exit}' /proc/cpuinfo)
if [[ -z "$CPU_MHZ" ]]; then
  echo "Error: unable to detect CPU MHz" >&2
  exit 1
fi

# output table
RESULTS_FILE="results.txt"

# where Makefile writes the merged CoreMark logs
COREMARK_LOG="results/coremark_results.txt"

 setup() {
  echo "Setting up environment..."
  cd benchmarks
  make setup
  cd - >/dev/null
}

clean() {
  echo "Cleaning build artifacts and old results..."
  cd benchmarks
  make clean
  cd - >/dev/null
  rm -f "$RESULTS_FILE"
}

build() {
  echo "Building all benchmarks..."
  cd benchmarks
  make all
  cd - >/dev/null
}

run() {
  echo "Running all benchmarks..."
  cd benchmarks
  make run
  cd - >/dev/null
}

results() {
  local name="$1" ips="$2" per_mhz

  # create header if missing
  if ! grep -q '^Benchmark' "$RESULTS_FILE" 2>/dev/null; then
    {
      echo "CPU MHz: $CPU_MHZ"
      echo
      printf "%-20s | %12s | %15s\n" "Benchmark" "Iterations/s" "Iter/s per MHz"
      echo "---------------------| -------------- | ---------------"
    } > "$RESULTS_FILE"
  fi
 # compute per-MHz and append
  per_mhz=$(awk -v i="$ips" -v m="$CPU_MHZ" 'BEGIN{printf "%.4f", i/m}')
  printf "%-20s | %12.3f | %15s\n" "$name" "$ips" "$per_mhz" \
    >> "$RESULTS_FILE"

  # re-align columns
  column -t -s"|" "$RESULTS_FILE" > tmp && mv tmp "$RESULTS_FILE"
}
 parse_coremark() {
  local infile="${1:-$COREMARK_LOG}"

  if [[ ! -f "$infile" ]]; then
    echo "Error: input file '$infile' not found." >&2
    return 1
  fi

  awk '
    /^=== run[0-9]+\.log results ===/ {
      sub(/^=== /,""); sub(/ results ===$/,"")
      name=$0
    }
    /Iterations\/Sec/ {
      print name, $NF
    }
  ' "$infile" | while read -r name ips; do
    results "$name" "$ips"
  done

  echo "All CoreMark benchmarks parsed and results.txt updated."
}

main() {
  clean
  setup
  build
  run
  # parse the merged coremark log
  parse_coremark "$COREMARK_LOG"

  #altri parse_*
}

main

echo "------------------ All benchmarks done. Results saved in $RESULTS_FILE ------------------"
                 
