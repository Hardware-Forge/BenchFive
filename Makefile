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
	@mkdir -p $(RESULTS_DIR)
	@mkdir -p $(BIN_DIR) 


#compilo tutti i benchmark
all:
	(cd $(cpu_dir) && make all) && \
	@echo "Tutti i benchmark sono stati compilati con successo!"
	@echo "Esegui 'make run' per eseguire i benchmark."
run:
	(cd $(cpu_dir) && make getresults) && \
	@echo "Tutti i benchmark sono stati eseguiti con successo!"
	@echo "I risultati sono stati salvati in $(RESULTS_DIR)."

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/CPU clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

clean_results:
	rm -rf $(RESULTS_DIR)/*
