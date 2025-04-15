.PHONY: all run clean
#directory di output
RESULTS_DIR := results
BIN_DIR := bin
memory_dir := benchmarks/memory
cpu_dir := benchmarks/CPU
io_dir := benchmarks/IO
syslevel_dir := benchmarks/syslevel
gpu_dir := benchmarks/GPU

setup:
	git submodule update --init --recursive
	@mkdir -p $(RESULTS_DIR)
	@mkdir -p $(BIN_DIR) 


#compilo tutti i benchmark
all:
	$(MAKE) -C $(cpu_dir) all
	@echo "Build completata"
run:
	(cd $(cpu_dir) && make getresults) && \
	@echo "Tutti i benchmark sono stati eseguiti con successo!"
	@echo "I risultati sono stati salvati in $(RESULTS_DIR)."

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/CPU clean
	$(MAKE) -C benchmarks/syslevel clean
	$(MAKE) -C benchmarks/IO clean
	$(MAKE) -C benchmarks/memory clean
	$(MAKE) -C benchmarks/GPU clean
	$(MAKE) -C benchmarks clean
	@phoronix-test-suite remove cachebench
	@phoronix-test-suite remove unpack-linux
	@apt remove --purge phoronix-test-suite -y
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

clean_results:
	rm -rf $(RESULTS_DIR)/*
