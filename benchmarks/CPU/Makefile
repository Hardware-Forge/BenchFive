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

	rm -rf _o || true
	rm -rf $(BIN_DIR)/*
	rm -rf "$(SOFTFLOAT_DIR)"
	rm -rf $(COREMARK_PRO_BIN_DIR)/*
	rm -rf $(COREMARK_PRO_BIN_DIR)/*
	rm -f $(BIN_DIR)/whetstone
	rm -f whetstone/whetstone

clean_results:
	rm -rf $(RESULTS_DIR)/*


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
