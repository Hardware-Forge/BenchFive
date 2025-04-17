.PHONY: all clean clean_results run getresults coremark getresultscoremark coremark_pro getresultscoremark-pro

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin


all: coremark getresultscoremark coremark-pro 
#linpack setup_testfloat testfloat whetstone 7zip Zstandard cpuminer stockfish canneal 

getresults: getresultscoremark getresultscoremark-pro 
#getresultssynchrobench getresultsdhrystone  dhrystone tolti

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C whetstone clean  || true
	$(MAKE) -C coremark-pro clean || true

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
	$(MAKE) -C coremark-pro TARGET=linux64
	
COREMARK_PRO_BIN_DIR = coremark-pro/builds/linux64/gcc64/bin
COREMARK_PRO_RESULTS_DIR = $(RESULTS_DIR)/coremark-pro

FORCE:

#coremark-pro execution and saving the score in results
getresultscoremark-pro:
	@mkdir -p $(COREMARK_PRO_RESULTS_DIR)
	@for bench in $(shell ls $(COREMARK_PRO_BIN_DIR)); do \
		echo "Running $$bench..."; \
		$(COREMARK_PRO_BIN_DIR)/$$bench > $(COREMARK_PRO_RESULTS_DIR)/$$bench.txt 2>&1; \
	done
	@echo "CoreMark-Pro results saved in $(COREMARK_PRO_RESULTS_DIR)"



# 7zip:
# 	cd 7zip/CPP/7zip/Bundles/LzmaCon && \
# 	$(MAKE) PLATFORM=riscv CC=riscv64-linux-gnu-gcc
# 	cp 7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma $(BIN_DIR)/
# 	@echo "7zip build completato e copiato in $(BIN_DIR)"


# getresults7zip:
# 	@mkdir -p $(RESULTS_DIR)
# 	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
# 	@echo "Risultati di 7zip salvati in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"
