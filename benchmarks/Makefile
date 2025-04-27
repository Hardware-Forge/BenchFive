.PHONY: all clean setup install_sysbench install_stress_ng getresults getresultssysbench_cpu getresultssysbench_memory getresultssysbench_fileio getresultssysbench_mutex getresultssysbench_thread getresultsstress-ng_mv getresultsstress-ng_ram getresultsstress-ng_cputemp clean_results
#directory di output
RESULTS_DIR := ../results
BIN_DIR := ../bin

setup:
	@apt install libmysqlclient-dev
	@apt install libck-dev
	@apt install -y \
          automake autoconf libtool pkg-config \
          lua5.3 liblua5.3-dev \
          libck-dev


all: setup && install_sysbench install_stress_ng

getresults: getresultssysbench_cpu getresultssysbench_memory getresultssysbench_fileio getresultssysbench_mutex getresultssysbench_thread getresultsstress-ng_mv getresultsstress-ng_ram getresultsstress-ng_cputemp
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
	rm -f $(RESULTS_DIR)/stress-ng_cputemp.txt

#-------------------------------------------------------stress-ng-------------------------------------------------------
install_stress_ng:
	(cd stress-ng && CC=gcc make clean && CC=gcc make && make install)
getresultsstress-ng_mv:
	@stress-ng --vm 2 --vm-bytes 2G --timeout 20s --metrics-brief > $(RESULTS_DIR)/stress-ng_mv.txt
getresultsstress-ng_ram:
	@stress-ng --vm 4 --vm-bytes 1G --timeout 20s --metrics-brief > $(RESULTS_DIR)/stress-ng_ram.txt
getresultsstress-ng_cputemp:
	@stress-ng --cpu 0 --tz -t 60s > $(RESULTS_DIR)/stress-ng_cputemp.txt
#-------------------------------------------------------sysbench-------------------------------------------------------
#installazione di sysbench
install_sysbench3:
	@echo "=== Generazione script di configurazione sysbench ==="
	(cd sysbench && ./autogen.sh)
	@echo "=== Configuro sysbench per usare Lua e Concurrency Kit di sistema ==="
	(cd sysbench && ./configure --with-system-luajit --with-system-ck)
	@echo "=== Compilo e installo sysbench ==="
	(cd sysbench && make -j$(nproc) && make install)

getresultssysbench_memory:
	@echo "Esecuzione di sysbench..."
	@sysbench memory --memory-block-size=1M --memory-total-size=8G run > $(RESULTS_DIR)/sysbench_memory.txt

getresultssysbench_fileio:
	@sysbench fileio --file-total-size=1G prepare
	@sysbench fileio --file-total-size=1G --file-test-mode=rndrw run > $(RESULTS_DIR)/sysbench_fileio.txt
	@sysbench fileio --file-total-size=1G cleanup



#-------------------------------------------------------cpu-------------------------------------------------------
getresultssysbench_cpu:
	@echo "Esecuzione di sysbench..."
	@sysbench cpu --cpu-max-prime=20000 run > $(RESULTS_DIR)/sysbench_cpu.txt
getresultssysbench_mutex:
	@sysbench mutex --mutex-num=1000 --mutex-locks=1000000 run > $(RESULTS_DIR)/sysbench_mutex.txt
getresultssysbench_thread:
	@sysbench threads --threads=2 --thread-yields=1000 --thread-locks=2 --thread-locks=1000 run > $(RESULTS_DIR)/sysbench_thread.txt

