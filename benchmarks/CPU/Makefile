.PHONY: all clean run coremark getresultscoremark testfloat getresultstestfloat linpack getresultslinpack setup_testfloat whetstone getresultswhetstone dhrystone getresultsdhrystone run_perf synchrobench getresultssynchrobench 7zip getresults7zip Zstandard getresultszstandard install_perf un_perf stockfish getresultsstockfish clean_results getresults

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: coremark dhrystone linpack testfloat whetstone synchrobench 7zip Zstandard cpuminer

getresults: getresultscoremark getresultsdhrystone getresultslinpack getresultstestfloat getresultswhetstone getresultssynchrobench getresults7zip getresultsZstandard


clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C linpack clean || true
	$(MAKE) -C testfloat clean || true
	$(MAKE) -C dhrystone clean || true
	$(MAKE) -C whetstone clean || true	
	$(MAKE) -C synchrobench clean || true
	$(MAKE) -C 7zip clean || true
	$(MAKE) -C Zstandard clean || true
	cd 7zip/CPP/7zip/Bundles/LzmaCon && \
    $(MAKE) -f makefile.gcc clean || true && \
	$(MAKE) -C stockfish/src clean || true
	rm -rf _o || true
	rm -rf $(BIN_DIR)/*
	rm -rf "$(SOFTFLOAT_DIR)"
	rm -f $(BIN_DIR)/whetstone
	rm -f whetstone/whetstone

clean_results:
	rm -rf $(RESULTS_DIR)/*


#---------------------------------------------------Integer ALU performance----------------------------------------------

coremark: 
	$(MAKE) -C coremark
	find coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;


#coreMark execution and saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"


#probabilmente questo necessita di un cross compiler perche è gia per risc v (al momento ho messo dei - per ignorare gli errori ma non va lo stesso)
dhrystone:
	-$(MAKE) -C dhrystone
	-find dhrystone -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

getresultsdhrystone: | $(RESULTS_DIR)
	@dhrystone/dhrystone > $(RESULTS_DIR)/dhrystone_results.txt
	echo "Risultati di Dhrystone salvati in $(RESULTS_DIR)/dhrystone_results.txt"



#---------------------------------------------------Floating point performance----------------------------------------------

linpack:
	$(MAKE) -C linpack
	find linpack -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

#linpack execution and saving the score in results
getresultslinpack: | $(RESULTS_DIR)
	@linpack/linpack > $(RESULTS_DIR)/linpack_results.txt
	echo "Risultati di Linpack salvati in $(RESULTS_DIR)/linpack_results.txt"


testfloat: 
	$(MAKE) -C testfloat/build/Linux-x86_64-GCC all
	find testfloat -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;
#nota: sui risultati di testfloat c'è una vasta scelta di funzioni vediamo poi cosa vogliamo fare (magari chiedere all'utente cosa vuole runnare), per ora ho fatto una all
getresultstestfloat: | $(RESULTS_DIR)
	@-testfloat/build/Linux-x86_64-GCC/testfloat -all1 > $(RESULTS_DIR)/testfloat_results.txt
	echo "Risultati di Testfloat salvati in $(RESULTS_DIR)/testfloat_results.txt"
#altra nota: da un errore a riga 49 ma probabilmente è perche lanciando il test il mio pc non li passa tutti quindi fornisce un erroe (ho messo @- per ignorare)

#managing testfloat dependencies
ROOT_DIR := "$(CURDIR)"

SOFTFLOAT_DIR := $(ROOT_DIR)/berkeley-softfloat-3
SOFTFLOAT_REPO := https://github.com/ucb-bar/berkeley-softfloat-3.git
SOFTFLOAT_BUILD_DIR := $(SOFTFLOAT_DIR)/build/Linux-x86_64-GCC

setup_testfloat:
	@echo "Cartella di lavoro: $(ROOT_DIR)"
	@if [ ! -d "$(SOFTFLOAT_DIR)" ]; then \
		echo "Clonazione di Berkeley SoftFloat..."; \
		git clone $(SOFTFLOAT_REPO) "$(SOFTFLOAT_DIR)"; \
	else \
		echo "Berkeley SoftFloat già presente."; \
	fi
	@echo "Compilazione di Berkeley SoftFloat..."
	@mkdir -p "$(SOFTFLOAT_BUILD_DIR)"
	@cd "$(SOFTFLOAT_BUILD_DIR)" && make

whetstone: whetstone/whetstone.c | $(BIN_DIR)
	gcc -o $(BIN_DIR)/whetstone whetstone/whetstone.c -lm

#whetstone 100000 it represents tge number of loops, it can be changed
getresultswhetstone: | $(RESULTS_DIR)
	../../bin/whetstone 100000 > ../../results/whetstone_results.txt
	@echo "Risultati di Whetstone salvati in $(RESULTS_DIR)/whetstone_results.txt"



#---------------------------------------------------Branch Prediction----------------------------------------------

install_perf:
	sudo apt-get install linux-tools-common linux-tools-generic
	sudo apt update && sudo apt install -y linux-tools-common linux-tools-generic linux-tools-$(shell uname -r)

run_perf: | $(RESULTS_DIR) install_perf
	mkdir -p $(RESULTS_DIR)
	sudo perf stat -a -e branch-misses,branches sleep 5 > $(RESULTS_DIR)/perf_results.txt 2>&1
	@echo "Risultati di perf salvati in $(RESULTS_DIR)/perf_results.txt"

#2>&1 → Reindirizza sia l'output standard che gli errori nel file


#---------------------------------------------------Concurrency----------------------------------------------

synchrobench: | $(BIN_DIR)
	$(MAKE) -C synchrobench/c-cpp
	cp synchrobench/c-cpp/bin/* $(BIN_DIR)/

getresultssynchrobench: | $(RESULTS_DIR)
	@echo "Eseguo Synchrobench..." > $(RESULTS_DIR)/synchrobench_results.txt
	@for exe in $(BIN_DIR)/*; do \
		if [ -x $$exe ]; then \
			echo "Eseguendo $$exe..." >> $(RESULTS_DIR)/synchrobench_results.txt; \
			$$exe >> $(RESULTS_DIR)/synchrobench_results.txt 2>&1; \
			echo "" >> $(RESULTS_DIR)/synchrobench_results.txt; \
		fi \
	done
	@echo "Risultati di Synchrobench salvati in $(RESULTS_DIR)/synchrobench_results.txt"


#---------------------------------------------------Compression/Decompression----------------------------------------------


7zip:
	cd 7zip/CPP/7zip/Bundles/LzmaCon && \
	$(MAKE) -f makefile.gcc
	cp 7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma $(BIN_DIR)/
	@echo "7zip build completato e copiato in $(BIN_DIR)"


getresults7zip:
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
	@echo "Risultati di 7zip salvati in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"

Zstandard:
	$(MAKE) -C Zstandard
	find Zstandard/programs/zstd -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

getresultsZstandard: | $(RESULTS_DIR)
	./Zstandard/programs/zstd -b10000000 -i10 > $(RESULTS_DIR)/zstandard_results.txt 
	echo "Test su 10 MB di buffer ripetuto 10 volte"
	echo "Risultati di zstandard salvati in $(RESULTS_DIR)/zstandard_results.txt"


#---------------------------------------------------SIMD perfomrmance----------------------------------------------

STOCKFISH_ARCH ?= native  # Modifica questo valore se vuoi un target specifico (es. x86-64-avx2)
STOCKFISH_TARGET = profile-build  # Usa PGO (Profile-Guided Optimization)

stockfish:
	$(MAKE) -C stockfish/src -j $(shell nproc) $(STOCKFISH_TARGET) ARCH=$(STOCKFISH_ARCH)
	find stockfish/src -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;
	@echo "Stockfish compilato con ARCH=$(STOCKFISH_ARCH)"

STOCKFISH_DIR := stockfish/src
BENCH_HASH := 128  # hash MB
BENCH_THREADS := $(shell nproc --all) #it stresses all the cores
BENCH_TIME := 5000  # [ms]
BENCH_DEPTH := 24   # max depth

getresultsstockfish: | $(RESULTS_DIR)
	@$(STOCKFISH_DIR)/stockfish bench $(BENCH_HASH) $(BENCH_THREADS) $(BENCH_DEPTH) default depth > $(RESULTS_DIR)/stockfish_results.txt 2>&1
	@echo "Risultati salvati in $(RESULTS_DIR)/stockfish_results.txt"