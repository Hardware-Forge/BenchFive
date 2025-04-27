#---------------------------------------------------CPU Makefile------------------------------------------------

.PHONY: all clean clean_results run getresults coremark getresultscoremark coremark_pro getresultscoremark-pro 7zip getresults7zip
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
