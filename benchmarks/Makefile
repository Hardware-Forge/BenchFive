.PHONY: all clean setup install_stress_ng getresults getresultsstress-ng_mv getresultsstress-ng_ram getresultsstress-ng_cputemp clean_results
#directory di output
RESULTS_DIR := ../results
BIN_DIR := ../bin


all: install_stress_ng

getresults: getresults_stress-ng_vm getresults_stress-ng_cputemp
# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/stress-ng clean || true
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt || true
	rm -f $(RESULTS_DIR)/stress-ng_ram.txt || true

clean_results:
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt || true
	rm -f $(RESULTS_DIR)/stress-ng_cputemp.txt || true

#-------------------------------------------------------stress-ng-------------------------------------------------------
install_stress_ng:
	(cd stress-ng && CC=gcc make clean && CC=gcc make -j$(nproc))
	cp stress-ng/stress-ng $(BIN_DIR)/stress-ng
getresults_stress-ng_vm:
	@echo "running stress-ng vm test for 20 seconds..."
	@./stress-ng/stress-ng --vm 4 --vm-bytes 2G --tz -t 20s --metrics-brief > $(RESULTS_DIR)/stress-ng_vm.txt
getresults_stress-ng_cputemp:
	@echo "running stress-ng cpu temperature test for 60 seconds..."
	@./stress-ng/stress-ng --cpu 0 --tz -t 60s > $(RESULTS_DIR)/stress-ng_cputemp.txt