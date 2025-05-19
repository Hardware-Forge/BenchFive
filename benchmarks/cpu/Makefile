#---------------------------------------------------CPU Makefile------------------------------------------------

.PHONY: all clean clean_results run getresults coremark getresults_coremark coremark_pro getresults_coremark-pro 7zip getresults_7zip stockfish getresults_stockfish install_geekbench getresults_geekbench 


#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

$(RESULTS_DIR):
	@mkdir -p $@


all: coremark coremark-pro 7zip stockfish install_geekbench
	@echo "All benchmarks compiled successfully."

getresults: getresults_coremark getresults_coremark-pro getresults_7zip getresults_stockfish getresults_geekbench
	@echo "All benchmark run successfully, results saved in $(RESULTS_DIR)."

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C whetstone clean  || true
	$(MAKE) -C coremark-pro clean || true
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon clean || true
	find 7zip/CPP/7zip -type f \( -name '*.o' -o -name '*.obj' \) -delete || true
	find 7zip/CPP/7zip/Bundles -type f \( -executable -o -name '*.exe' -o -name '*.dll' \) -delete || true
	$(MAKE) -C stockfish/src clean-all || true
	@echo " → Removing binaries and compiled files"
	@$(MAKE) -C stockfish/src objclean       || true
	@echo " → Removing profile data"
	@$(MAKE) -C stockfish/src profileclean   || true
	@if [ -d "Geekbench-6.4.0-LinuxRISCVPreview" ]; then \
	  rm -rf -- "Geekbench-6.4.0-LinuxRISCVPreview"; \
	else \
	  echo "→ No Geekbench to remove"; \
	fi


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
getresults_coremark: | $(RESULTS_DIR)
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


getresults_coremark-pro: | $(RESULTS_DIR)
	@echo "Running all Coremark-PRO workloads..."
	$(MAKE) -C coremark-pro TARGET=linux64 XCMD='-c4' certify-all > $(RESULTS_DIR)/coremark-pro_results.txt


#---------------------------------------------------Data compression----------------------------------------------


7zip:
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon \
	-f makefile.gcc 
	@echo "7zip build completato"

getresults_7zip: | $(RESULTS_DIR)
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_results.txt
	@echo "7zip results saved in $(RESULTS_DIR)/7zip_results.txt"


#---------------------------------------------------SIMD performance---------------------------------------------

STOCKFISH_ARCH := riscv64 

stockfish:
	$(MAKE) -C stockfish/src -j1 build ARCH=$(STOCKFISH_ARCH)
	@echo "Stockfish compiled with ARCH=$(STOCKFISH_ARCH)"

getresults_stockfish: | $(RESULTS_DIR)
	./stockfish/src/stockfish bench > $(RESULTS_DIR)/stockfish_results.txt 2>&1
	@echo "Stockfish results saved in $(RESULTS_DIR)/stockfish_results.txt"


#-----------------------------------------------------General---------------------------------------------

GEEK_DIR := $(RESULTS_DIR)

install_geekbench:
	@echo "Scaricamento e installazione di Geekbench 6..."
	curl -O https://cdn.geekbench.com/Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	tar -xvzf Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	rm Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	@echo "Geekbench 6 successfully installed in current directory."

getresults_geekbench: | $(RESULTS_DIR)
	@echo "Esecuzione di Geekbench 6..."
	cd Geekbench-6.4.0-LinuxRISCVPreview && ./geekbench6 > $(GEEK_DIR)/geekbench_results.txt 2>&1
	@echo "Geekbench 6 results saved in $(GEEK_DIR)/geekbench_results.txt"
