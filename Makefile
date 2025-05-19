#---------------------------------------------------Main Makefile------------------------------------------------

.PHONY: all run clean
#directory di output
RESULTS_DIR := results
BIN_DIR := bin
memory_dir := benchmarks/memory
cpu_dir := benchmarks/cpu
io_dir := benchmarks/io
gpu_dir := benchmarks/gpu

setup:
	git submodule update --init --recursive
	@mkdir -p $(RESULTS_DIR)
	@mkdir -p $(BIN_DIR) 


# Compilazione di tutti i benchmark
all:
	$(MAKE) -C $(cpu_dir) all
	$(MAKE) -C $(memory_dir) all
	$(MAKE) -C $(io_dir) all
	$(MAKE) -C $(syslevel_dir) all
	$(MAKE) -C $(gpu_dir) all
	@echo "Build completata"

# Esecuzione di tutti i benchmark e salvataggio dei risulati in results
run:
	$(MAKE) -C $(cpu_dir) getresults
	$(MAKE) -C $(memory_dir) getresults
	$(MAKE) -C $(io_dir) getresults
	$(MAKE) -C $(syslevel_dir) getresults
	$(MAKE) -C $(gpu_dir) getresults

	@echo "Esecuzione benchmarks completata"

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/cpu clean
	$(MAKE) -C benchmarks/memory clean
	$(MAKE) -C benchmarks/io clean
	$(MAKE) -C benchmarks/gpu clean
	$(MAKE) -C benchmarks clean
	@if [ -n "$(RESULTS_DIR)" ] && [ -d "$(RESULTS_DIR)" ] && [ "$(RESULTS_DIR)" != "/" ]; then \
		rm -f "$(RESULTS_DIR)"/*; \
	fi

clean_results:
	@if [ -n "$(RESULTS_DIR)" ] && [ -d "$(RESULTS_DIR)" ] && [ "$(RESULTS_DIR)" != "/" ]; then \
		rm -f "$(RESULTS_DIR)"/*;
	fi

