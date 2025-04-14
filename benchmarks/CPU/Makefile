.PHONY: all clean run coremark 7zip getresults coremark_pro clean_results

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: coremark 
#linpack setup_testfloat testfloat whetstone 7zip Zstandard cpuminer stockfish canneal 

getresults: getresultscoremark 
#getresultssynchrobench getresultsdhrystone  dhrystone tolti

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C whetstone clean 

	rm -rf _o || true
	rm -rf $(BIN_DIR)/*
	rm -rf "$(SOFTFLOAT_DIR)"
	rm -f $(BIN_DIR)/whetstone
	rm -f whetstone/whetstone

clean_results:
	rm -rf $(RESULTS_DIR)/*


#---------------------------------------------------Integer ALU performance----------------------------------------------

coremark:
	$(MAKE) -C coremark CC=riscv64-linux-gnu-gcc
	find coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;


#coreMark execution and saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"


coremark_pro:
	$(MAKE) -C coremark-pro CC=riscv64-linux-gnu-gcc
	find coremark-pro -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

#coreMark-pro execution and saving the score in results
getresultscoremark-pro: | $(RESULTS_DIR)
	@coremark-pro/coremark_pro.exe > $(RESULTS_DIR)/coremark_pro_results.txt
	echo "Results of CoreMark-pro saved in $(RESULTS_DIR)/coremark_pro_results.txt"




7zip:
	cd 7zip/CPP/7zip/Bundles/LzmaCon && \
	$(MAKE) PLATFORM=riscv CC=riscv64-linux-gnu-gcc
	cp 7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma $(BIN_DIR)/
	@echo "7zip build completato e copiato in $(BIN_DIR)"


getresults7zip:
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
	@echo "Risultati di 7zip salvati in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"
