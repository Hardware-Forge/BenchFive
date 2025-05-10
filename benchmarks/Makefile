.PHONY: all clean setup install_sysbench install_stress_ng getresults getresultssysbench_cpu getresultssysbench_memory getresultssysbench_fileio getresultssysbench_mutex getresultssysbench_thread getresultsstress-ng_mv getresultsstress-ng_ram getresultsstress-ng_cputemp clean_results
#directory di output
RESULTS_DIR := ../results
BIN_DIR := ../bin


all: install_stress_ng

getresults: getresultsstress-ng_ram getresultsstress-ng_cputemp
# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/sysbench clean
	$(MAKE) -C benchmarks/stress-ng clean
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt
	rm -f $(RESULTS_DIR)/stress-ng_ram.txt

clean_results:
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt
	rm -f $(RESULTS_DIR)/stress-ng_cputemp.txt

#-------------------------------------------------------stress-ng-------------------------------------------------------
install_stress_ng:
	(cd stress-ng && CC=gcc make clean && CC=gcc make -j$(nproc))
	cp stress-ng/stress-ng $(BIN_DIR)/stress-ng
getresultsstress-ng_vm:
	@echo "running stress-ng vm test for 20 seconds..."
	@./stress-ng/stress-ng --vm 4 --vm-bytes 2G --tz -t 20s --metrics-brief > $(RESULTS_DIR)/stress-ng_vm.txt
getresultsstress-ng_cputemp:
	@echo "running stress-ng cpu temperature test for 60 seconds..."
	@./stress-ng/stress-ng --cpu 0 --tz -t 60s > $(RESULTS_DIR)/stress-ng_cputemp.txt