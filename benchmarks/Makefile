#directory di output
RESULTS_DIR := ../results
BIN_DIR := ../bin
all: getresultssysbench_cpu getresultssysbench_memory getresultssysbench_fileio getresultssysbench_mutex getresultssysbench_thread
# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/IO/sysbench clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

clean_results:
	rm -rf $(RESULTS_DIR)/*


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