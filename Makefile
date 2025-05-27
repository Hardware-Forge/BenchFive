#---------------------------------------------------Main Makefile------------------------------------------------

.PHONY: all run clean
# Output directories
RESULTS_DIR := results
BIN_DIR := bin
memory_dir := benchmarks/memory
cpu_dir := benchmarks/cpu
io_dir := benchmarks/io
gpu_dir := benchmarks/gpu
ai_dir := benchmarks/ai
temp_dir := benchmarks

setup:
	git submodule update --init --recursive
	@mkdir -p $(RESULTS_DIR)
	@mkdir -p $(BIN_DIR) 
	apt-get install gawk


# Compile all benchmarks
all:
	$(MAKE) -C $(cpu_dir) all
	$(MAKE) -C $(memory_dir) all
	$(MAKE) -C $(io_dir) all
	$(MAKE) -C $(gpu_dir) all
	$(MAKE) -C $(ai_dir) all
	$(MAKE) -C $(temp_dir) all
	@echo "Build completed"

# Run all benchmarks and save results in results directory
run:
	$(MAKE) -C $(cpu_dir) getresults
	$(MAKE) -C $(memory_dir) getresults
	$(MAKE) -C $(io_dir) getresults
	$(MAKE) -C $(gpu_dir) getresults
	$(MAKE) -C $(ai_dir) getresults
	$(MAKE) -C $(temp_dir) getresults

	@echo "Benchmark execution completed"

# Clean all benchmarks
clean:
	$(MAKE) -C benchmarks/cpu clean
	$(MAKE) -C benchmarks/memory clean
	$(MAKE) -C benchmarks/io clean
	$(MAKE) -C benchmarks/gpu clean
	$(MAKE) -C benchmarks clean
	$(MAKE) -C benchmarks/ai clean
	$(MAKE) -C benchmarks clean
	@if [ -n "$(RESULTS_DIR)" ] && [ -d "$(RESULTS_DIR)" ] && [ "$(RESULTS_DIR)" != "/" ]; then \
		rm -f "$(RESULTS_DIR)"/*; \
	fi

clean_results:
	@if [ -n "$(RESULTS_DIR)" ] && [ -d "$(RESULTS_DIR)" ] && [ "$(RESULTS_DIR)" != "/" ]; then \
		rm -f "$(RESULTS_DIR)"/*;
	fi

