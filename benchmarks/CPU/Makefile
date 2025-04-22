#---------------------------------------------------CPU Makefile------------------------------------------------

.PHONY: all clean clean_results run getresults coremark getresultscoremark coremark_pro getresultscoremark-pro_singlecore getresultscoremark-pro_multicore 7zip getresults7zip

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin


all: coremark getresultscoremark coremark-pro 7zip
#linpack setup_testfloat testfloat whetstone 7zip Zstandard cpuminer stockfish canneal 

getresults: getresultscoremark getresultscoremark-pro_singlecore getresultscoremark-pro_multicore getresults7zip
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
COREMARK_PRO_SC_RESULTS_DIR = $(COREMARK_PRO_RESULTS_DIR)/singlecore
COREMARK_PRO_MC_RESULTS_DIR = $(COREMARK_PRO_RESULTS_DIR)/multicore
COREMARK_PRO_SUMMARY_SINGLE   = $(COREMARK_PRO_SC_RESULTS_DIR)/coremark-pro_singlecore_results.txt
COREMARK_PRO_SUMMARY_MULTI    = $(COREMARK_PRO_MC_RESULTS_DIR)/coremark-pro_multicore_results.txt
# Numero di contesti (thread) per default: core disponibili
THREADS ?= $(shell nproc)

FORCE:

# Execution of coremark-pro singlecore execution and saving the score in results
getresultscoremark-pro_singlecore:
	@mkdir -p $(COREMARK_PRO_RESULTS_DIR)
	@mkdir -p $(COREMARK_PRO_SC_RESULTS_DIR)
	@echo "Running all workloads in single-core (1 context)..."
	@for bench in $(shell ls $(COREMARK_PRO_BIN_DIR)); do \
		echo " - $$bench"; \
		$(COREMARK_PRO_BIN_DIR)/$$bench > $(COREMARK_PRO_SC_RESULTS_DIR)/$$bench.txt 2>&1; \
	done
	@echo "Generating single-core summary..."
	@awk 'BEGIN { sum=0; count=0; print "CoreMark-Pro Single-Core Results\n================================" } \
	/(items|workloads)\/sec/ { \
		file=FILENAME; sub(/.*\//, "", file); split($$0, parts, "="); val=parts[2]; \
		print file": "val" items/sec"; sum+=val; count++; \
	} \
	END { if (count>0) printf "\nScore: %.6f\n", sum/count; else print "\nScore: 0.000000" }' $(COREMARK_PRO_SC_RESULTS_DIR)/*.txt > $(COREMARK_PRO_SUMMARY_SINGLE)
	@find $(COREMARK_PRO_SC_RESULTS_DIR) -type f \
		! -name $(notdir $(COREMARK_PRO_SUMMARY_SINGLE)) -delete
	@echo "Single-core summary saved to $(COREMARK_PRO_SUMMARY_SINGLE)"

# Execution of coremark-pro multicore execution and saving the score in results
getresultscoremark-pro_multicore:
	@mkdir -p $(COREMARK_PRO_RESULTS_DIR)
	@mkdir -p $(COREMARK_PRO_MC_RESULTS_DIR)
	@rm -f $(COREMARK_PRO_MC_RESULTS_DIR)/*.txt
	@echo "Running all workloads in multi-core ($(THREADS) contexts)..."
	@for bench in $(shell ls $(COREMARK_PRO_BIN_DIR)); do \
		echo " - $$bench"; \
		$(COREMARK_PRO_BIN_DIR)/$$bench -v0 -c$(THREADS) \
			> $(COREMARK_PRO_MC_RESULTS_DIR)/$$bench.txt 2>&1; \
	done
	@echo "Generating multi-core summary..."
	@awk 'BEGIN { sum=0; count=0; print "CoreMark-Pro Multi-Core Results\n================================" } \
	/(items|workloads)\/sec/ { \
		file=FILENAME; sub(/.*\//,"",file); split($$0,parts,"="); \
		val=parts[2]; gsub(/[^0-9\.]/,"",val); \
		print file": "val" items/sec"; sum+=val; count++; \
	} \
	END { if (count>0) printf "\nScore: %.6f\n", sum/count; else print "\nScore: 0.000000" }' \
		$(COREMARK_PRO_MC_RESULTS_DIR)/*.txt > $(COREMARK_PRO_SUMMARY_MULTI)
	@find $(COREMARK_PRO_MC_RESULTS_DIR) -type f \
		! -name $(notdir $(COREMARK_PRO_SUMMARY_MULTI)) -delete
	@echo "Multi-core summary saved to $(COREMARK_PRO_SUMMARY_MULTI)"



#---------------------------------------------------Data compression----------------------------------------------


7zip:
	$(MAKE) -C 7zip/CPP/7zip/Bundles/LzmaCon \
	        -f makefile.gcc 
	cp 7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma $(BIN_DIR)/
	@echo "7zip build completato e copiato in $(BIN_DIR)"



getresults7zip:
	@mkdir -p $(RESULTS_DIR)
	7zip/CPP/7zip/Bundles/LzmaCon/_o/lzma b > $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt
	@echo "Risultati di 7zip salvati in $(RESULTS_DIR)/7zip_bench_$(TIMESTAMP).txt"
