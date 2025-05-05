#---------------------------------------------------CPU Makefile------------------------------------------------

.PHONY: all clean clean_results run getresults coremark getresultscoremark coremark_pro getresultscoremark-pro 7zip getresults7zip install_geekbench getresults_geekbench stockfish getresultsstockfish


#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin


all: coremark coremark-pro 7zip stockfish

getresults: getresultscoremark getresultscoremark-pro getresults7zip getresultsstockfish

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C whetstone clean  || true
	$(MAKE) -C coremark-pro clean || true
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon clean || true
	$(MAKE) -C stockfish/src clean-all || true
	@echo " → Removing binaries and compiled files"
	@$(MAKE) -C stockfish/src objclean       || true
	@echo " → Removing profile data"
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
	@echo "=== run1.log results ===" > $(RESULTS_DIR)/coremark_results.txt
	@cat coremark/run1.log >> $(RESULTS_DIR)/coremark_results.txt
	@echo "" >> $(RESULTS_DIR)/coremark_results.txt
	@echo "=== run2.log results ===" >> $(RESULTS_DIR)/coremark_results.txt
	@cat coremark/run2.log >> $(RESULTS_DIR)/coremark_results.txt
	@echo "CoreMark results saved in $(RESULTS_DIR)/coremark_results.txt"

#compiling
coremark-pro: FORCE
	$(MAKE) -C coremark-pro TARGET=linux64 build


FORCE:
	@echo "Compiling Coremark-PRO..."


getresultscoremark-pro:
	@echo "Running all Coremark-PRO workloads..."
	$(MAKE) -C coremark-pro TARGET=linux64 XCMD='-c4' certify-all > $(RESULTS_DIR)/coremark-pro.txt


#---------------------------------------------------Data compression----------------------------------------------


7zip:
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon \
	        -f makefile.gcc 
	@echo "7zip build completato"



getresults7zip:
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
	@echo "7zip results saved in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"

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


 STOCKFISH_DIR := stockfish/src
 BENCH_THREADS := $(shell nproc --all) #it stresses all the cores
 BENCH_TIME := 5000  # [ms]
 BENCH_DEPTH := 24   # max depth

STOCKFISH_ARCH := riscv64  # Modifica questo valore se vuoi un target specifico (es. x86-64-avx2)
STOCKFISH_TARGET = profile-build  # Usa PGO (Profile-Guided Optimization)

stockfish:
	$(MAKE) -C stockfish/src -j1 build ARCH=$(STOCKFISH_ARCH)
	@echo "Stockfish compiled with ARCH=$(STOCKFISH_ARCH)"

getresultsstockfish:
	./stockfish/src/stockfish bench > $(RESULTS_DIR)/stockfish_results.txt 2>&1
	@echo "Stockfish results saved in $(RESULTS_DIR)/stockfish_results.txt"

