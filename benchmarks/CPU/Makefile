.PHONY: all clean run getresultscoremark coremark

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: coremark

clean:
	$(MAKE) -C coremark clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

#---------------------------------------------------Branch Prediction----------------------------------------------

coremark: 
	$(MAKE) -C coremark
	find coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;


#coreMark execution and saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"
	

#---------------------------------------------------Floating point performance----------------------------------------------

linpack:
	$(MAKE) -C benchmarks/CPU/linpack
	find benchmarks/CPU/linpack -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

#linpack execution and saving the score in results
getresultslinpack: | $(RESULTS_DIR)
	@benchmarks/CPU/linpack/linpack > $(RESULTS_DIR)/linpack_results.txt
	echo "Risultati di Linpack salvati in $(RESULTS_DIR)/linpack_results.txt"


testfloat: 
	$(MAKE) -C benchmarks/CPU/testfloat/build/Linux-x86_64-GCC all
	find benchmarks/CPU/testfloat -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

getresultstestfloat: | $(RESULTS_DIR)
	@benchmarks/CPU/testfloat/testfloat > $(RESULTS_DIR)/testfloat_results.txt
	echo "Risultati di Testfloat salvati in $(RESULTS_DIR)/testfloat_results.txt"
