#directory di output
RESULTS_DIR := ../results
BIN_DIR := ../bin
all: install_sysbench install_stress_ng

getresults: getresultssysbench_cpu getresultssysbench_memory getresultssysbench_fileio getresultssysbench_mutex getresultssysbench_thread getresultsstress-ng_mv getresultsstress-ng_ram
# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/sysbench clean
	$(MAKE) -C benchmarks/stress-ng clean
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt
	rm -f $(RESULTS_DIR)/stress-ng_ram.txt
	rm -f $(RESULTS_DIR)/sysbench_memory.txt
	rm -f $(RESULTS_DIR)/sysbench_fileio.txt
	rm -f $(RESULTS_DIR)/sysbench_cpu.txt
	rm -f $(RESULTS_DIR)/sysbench_mutex.txt
	rm -f $(RESULTS_DIR)/sysbench_thread.txt
	rm -f $(RESULTS_DIR)/sysbench.txt
	rm -f $(RESULTS_DIR)/sysbench_fileio.txt

clean_results:
	rm -f $(RESULTS_DIR)/stress-ng_mv.txt
	rm -f $(RESULTS_DIR)/stress-ng_ram.txt
	rm -f $(RESULTS_DIR)/sysbench_memory.txt
	rm -f $(RESULTS_DIR)/sysbench_fileio.txt
	rm -f $(RESULTS_DIR)/sysbench_cpu.txt
	rm -f $(RESULTS_DIR)/sysbench_mutex.txt
	rm -f $(RESULTS_DIR)/sysbench_thread.txt
	rm -f $(RESULTS_DIR)/sysbench.txt
	rm -f $(RESULTS_DIR)/sysbench_fileio.txt

#-------------------------------------------------------sysbench-------------------------------------------------------
#installazione di sysbench
install_sysbench:
	(cd sysbench && ./autogen.sh && ./configure && make -j && make install)

getresultssysbench_memory:
	@echo "Esecuzione di sysbench..."
	@sysbench memory --memory-block-size=1M --memory-total-size=8G run > $(RESULTS_DIR)/sysbench_memory.txt

getresultssysbench_fileio:
	@sysbench fileio --file-total-size=1G prepare
	@sysbench fileio --file-total-size=1G --file-test-mode=rndrw run > $(RESULTS_DIR)/sysbench_fileio.txt
	@sysbench fileio --file-total-size=1G cleanup



#-------------------------------------------------------cpudacontrollare-------------------------------------------------------
getresultssysbench_cpu:
	@echo "Esecuzione di sysbench..."
	@sysbench cpu --cpu-max-prime=20000 run > $(RESULTS_DIR)/sysbench_cpu.txt
getresultssysbench_mutex:
	@sysbench mutex --mutex-num=1000 --mutex-locks=1000000 run > $(RESULTS_DIR)/sysbench_mutex.txt
getresultssysbench_thread:
	@sysbench threads --threads=2 --thread-yields=1000 --thread-locks=2 --thread-locks=1000 run > $(RESULTS_DIR)/sysbench_thread.txt



#prova
#-------------------------------------------------------stress-ng-------------------------------------------------------
install_stress_ng:
	(cd stress-ng && CC=gcc gmake clean && CC=gcc gmake)
getresultsstress-ng_mv:
	@stress-ng --vm 2 --vm-bytes 2G --timeout 60s --metrics-brief > $(RESULTS_DIR)/stress-ng_mv.txt
getresultsstress-ng_ram:
	@stress-ng --vm 4 --vm-bytes 1G --timeout 60s --metrics-brief > $(RESULTS_DIR)/stress-ng_ram.txt

