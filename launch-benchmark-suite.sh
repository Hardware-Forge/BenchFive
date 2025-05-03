#!/bin/bash


# This script is used to automatically compile and run the benchmark suite.


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


#saving the resuts..... TODO
#
#
#
#



# The function will be launched automatically when the script is run
setup
clean
build
run

#-------------------------------------------------END----------------------------------------------------