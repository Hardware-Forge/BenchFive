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


install_phoronix_benchmarks:
	@$(MAKE) phoronix
	@$(MAKE) install_cachebench
	@$(MAKE) install_unpacking_linux_kernel
	


runphoronix:
	@echo "Esecuzione di Phoronix Test Suite..."
	@$(MAKE) getresultscachebench
	@$(MAKE) getresultsunpacking_linux_kernel
	

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


#-------------------------------------------------------phoronix-------------------------------------------------------
# Installa Phoronix Test Suite
phoronix:
	@echo "Installazione di Phoronix Test Suite..."
	@sudo apt update && sudo apt install -y phoronix-test-suite
	@echo "Phoronix Test Suite installato!"

# Installa benchmark specifici
install_cachebench:
	@echo "Installazione di cachebench..."
	@phoronix-test-suite install cachebench

install_unpacking_linux_kernel:
	@echo "Installazione di unpacking linux kernel..."
	@phoronix-test-suite install unpack-linux

# Esegui i benchmark specifici
getresultscachebench:
	@echo "🔧 Esecuzione di cachebench..."
	@printf "3\nn\n" | phoronix-test-suite run cachebench

getresultsunpacking_linux_kernel:
	@echo "🔧 Esecuzione di unpacking linux kernel..."
	@printf "n\n" | phoronix-test-suite run unpack-linux
#iozone da aggiungere in futuro (dura 1+ ora)
