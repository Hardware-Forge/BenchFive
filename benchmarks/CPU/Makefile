#---------------------------------------------------CPU Makefile------------------------------------------------

.PHONY: all clean clean_results run getresults coremark getresultscoremark coremark_pro getresultscoremark-pro 7zip getresults7zip install_geekbench getresults_geekbench stockfish getresultsstockfish
#getresultscoremark-pro_singlecore getresultscoremark-pro_multicore 7zip getresults7zip

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin


all: coremark coremark-pro 7zip
#linpack setup_testfloat testfloat whetstone 7zip Zstandard cpuminer stockfish canneal

getresults: getresultscoremark getresultscoremark-pro getresults7zip
#getresultscoremark-pro_singlecore getresultscoremark-pro_multicore getresults7zip
#getresultssynchrobench getresultsdhrystone  dhrystone tolti

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C whetstone clean  || true
	$(MAKE) -C coremark-pro clean || true
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon clean || true
	$(MAKE) -C stockfish/src clean-all || true
	@echo " → Rimuovo binari e oggetti compilati"
	@$(MAKE) -C stockfish/src objclean       || true
	@echo " → Rimuovo file di profiling e benchmark"
	@$(MAKE) -C stockfish/src profileclean   || true
	find 7zip/CPP/7zip -type f \( -name '*.o' -o -name '*.obj' \) -delete || true
	find 7zip/CPP/7zip/Bundles -type f \( -executable -o -name '*.exe' -o -name '*.dll' \) -delete || true


clean_results:
	@if [ -n "$(RESULTS_DIR)" ] && [ -d "$(RESULTS_DIR)" ] && [ "$(RESULTS_DIR)" != "/" ]; then \
		echo "Cleaning files in $(RESULTS_DIR)..."; \
		rm -f "$(RESULTS_DIR)"/*; \
	else \
		echo "ERROR: Invalid or unsafe RESULTS_DIR ('$(RESULTS_DIR)') — skipping clean."; \
		exit 1; \
	fi
	

#---------------------------------------------------Integer ALU performance----------------------------------------------

#coremark compiling and execution
coremark:
	$(MAKE) -C coremark 


#saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@echo "=== Risultato da run1.log ===" > $(RESULTS_DIR)/coremark_results.txt
	@cat coremark/run1.log >> $(RESULTS_DIR)/coremark_results.txt
	@echo "" >> $(RESULTS_DIR)/coremark_results.txt
	@echo "=== Risultato da run2.log ===" >> $(RESULTS_DIR)/coremark_results.txt
	@cat coremark/run2.log >> $(RESULTS_DIR)/coremark_results.txt
	@echo "Risultati di CoreMark copiati in $(RESULTS_DIR)/coremark_results.txt"

#compiling
coremark-pro: FORCE
	$(MAKE) -C coremark-pro TARGET=linux64 build


FORCE:
	@echo "Compilazione Coremark-PRO"


getresultscoremark-pro:
	@echo "Running all Coremark-PRO workloads"
	$(MAKE) -C coremark-pro TARGET=linux64 XCMD='-c4' certify-all > $(RESULTS_DIR)/coremark-pro.txt


#---------------------------------------------------Data compression----------------------------------------------


7zip:
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon \
	        -f makefile.gcc 
	@echo "7zip build completato"



getresults7zip:
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
	@echo "Risultati di 7zip salvati in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"

#---------------------------------------------------geekbench---------------------------------------------

install_geekbench:
	@echo "Scaricamento e installazione di Geekbench 6..."
	curl -O https://cdn.geekbench.com/Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	tar -xvzf Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	rm Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	@echo "Geekbench 6 installato nella directory corrente."

getresults_geekbench:
	@echo "Esecuzione di Geekbench 6..."
	cd Geekbench-6.4.0-LinuxRISCVPreview && ./geekbench6 > $(RESULTS_DIR)/geekbench.txt 2>&1
	@echo "Risultati di Geekbench 6 salvati in $(RESULTS_DIR)/geekbench.txt"


#---------------------------------------------------SIMD performance---------------------------------------------

# stockfish:
# 	$(MAKE) -C stockfish/src -j $(shell nproc) $(STOCKFISH_TARGET) ARCH=$(STOCKFISH_ARCH)
# 	@echo "Stockfish compilato con ARCH=$(STOCKFISH_ARCH)"

# getresultsstockfish: | $(RESULTS_DIR)
# 	@$(STOCKFISH_DIR)/stockfish bench $(BENCH_HASH) $(BENCH_THREADS) $(BENCH_DEPTH) default depth > $(RESULTS_DIR)/stockfish_results.txt 2>&1


 STOCKFISH_DIR := stockfish/src
 BENCH_THREADS := $(shell nproc --all) #it stresses all the cores
 BENCH_TIME := 5000  # [ms]
 BENCH_DEPTH := 24   # max depth

STOCKFISH_ARCH ?= native  # Modifica questo valore se vuoi un target specifico (es. x86-64-avx2)
STOCKFISH_TARGET = profile-build  # Usa PGO (Profile-Guided Optimization)

stockfish:
	$(MAKE) -C stockfish/src -j $(shell nproc) $(STOCKFISH_TARGET) ARCH=$(STOCKFISH_ARCH)
	@echo "Stockfish compilato con ARCH=$(STOCKFISH_ARCH)"

getresultsstockfish:
	./stockfish/src/stockfish bench > $(RESULTS_DIR)/stockfish_results.txt 2>&1
	@echo "Risultati di Stockfish salvati in $(RESULTS_DIR)/stockfish_results.txt"

