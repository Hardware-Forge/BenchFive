.PHONY: all
#directory di output
RESULTS_DIR := results
BIN_DIR := bin
memory_dir := benchmarks/memory
cpu_dir := benchmarks/CPU
io_dir := benchmarks/IO
syslevel_dir := benchmarks/syslevel
gpu_dir := benchmarks/GPU

setup:
	@git submodule update --init --recursive
	@apt-get install php-cli php-xml
	@apt-get install tmux


#compilo tutti i benchmark
all: 
	(cd $(memory_dir) $(MAKE) all) && 
	(cd $(io_dir) $(MAKE) all) &&
	(cd $(syslevel_dir) $(MAKE) all) &&
	(cd benchmarks $(MAKE) all)
run:
	(cd $(memory_dir) $(MAKE) getresults) && 
	(cd $(io_dir) $(MAKE) getresults) &&
	(cd $(syslevel_dir) $(MAKE) getresults) &&
	(cd benchmarks $(MAKE) getresults) &&
	(cd $(gpu_dirs) $(MAKE) getresults)
# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/CPU/coremark clean
	$(MAKE) -C benchmarks/syslevel/rt-tests clean
	$(MAKE) -C benchmarks/IO/fio clean
	$(MAKE) -C benchmarks/IO/sysbench clean
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
