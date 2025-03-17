.PHONY: all clean run getresultscyclictest getresultscoremark rt-tests run_hackbench hackbench

#ignorare benchmark-list/cyclictest l'ho fatto solo per capire come costruire un makefile con piu benchmark


#directory di output
RESULTS_DIR := results
BIN_DIR := bin


all: coremark rt-tests fio

# Pulizia per tutti i benchmark
clean:
	$(MAKE) -C benchmarks/CPU/coremark clean
	$(MAKE) -C benchmarks/syslevel/rt-tests clean
	$(MAKE) -C benchmarks/IO/fio clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*

coremark: 
	$(MAKE) -C benchmarks/CPU/coremark
	find benchmarks/CPU/coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \; 


#esecuzione di CoreMark e raccolta risultati in results
getresultscoremark: | $(RESULTS_DIR)
	@benchmarks/CPU/coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"

linpack:
	$(MAKE) -C benchmarks/CPU/linpack
	find benchmarks/CPU/linpack -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

#eseuzione di linpack e raccolta risultati in results
getresultslinpack: | $(RESULTS_DIR)
	@benchmarks/CPU/linpack/linpack > $(RESULTS_DIR)/linpack_results.txt
	echo "Risultati di Linpack salvati in $(RESULTS_DIR)/linpack_results.txt"

rt-tests: $(BIN_DIR) #mi assicuro esista la cartella prima di eseguire il make
	$(MAKE) -C benchmarks/syslevel/rt-tests all
	find benchmarks/syslevel/rt-tests -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \; 

#Esecuzione di hackbench
run_hackbench: | $(RESULTS_DIR)
	@benchmarks/syslevel/rt-tests/hackbench > $(RESULTS_DIR)/hackbench_results.txt
#Esecuzione di hwlatdetect
run_hwlatdetect:
	@benchmarks/syslevel/rt-tests/hwlatdetect > $(RESULTS_DIR)/hwlatdetect_results.txt
#Esecuzione di deadline_test
run_deadline_test:
	@benchmarks/syslevel/rt-tests/deadline_test > $(RESULTS_DIR)/deadline_test_results.txt
#Esecuzione di cyclictest
run_cyclictest:
	@benchmarks/syslevel/rt-tests/cyclictest -a -t -N -p99
#Esecuzione di get_cyclictest_snapshot
run_get_cyclictest_snapshot:
	@benchmarks/syslevel/rt-tests/get_cyclictest_snapshot > $(RESULTS_DIR)/cyclictest_results.txt
# Esecuzione cyclictest e raccolta risultati,non funziona bene
getresultscyclictest:
	tmux new-session -d -s cyclictest_session 'benchmarks/syslevel/rt-tests/cyclictest -a -t -N -p99'
	sleep 3
	@benchmarks/syslevel/rt-tests/get_cyclictest_snapshot > $(RESULTS_DIR)/cyclictest_results.txt
	sleep 3
	tmux kill-session -t cyclictest_session
	@echo "Risultati di Cyclictest salvati in $(RESULTS_DIR)/cyclictest_results.txt"

fio:
	(cd benchmarks/IO/fio && ./configure && $(MAKE) -C benchmarks/IO/fio all && $(MAKE) -C benchmarks/IO/fio install)
	$(MAKE) create_fio_file

create_fio_file:
	@printf "[global]\nioengine=libaio\ndirect=1\nbs=4k\nsize=10M\nruntime=120\ngroup_reporting\nunlink=1\n\n\
	[seq-read]\nrw=read\nnumjobs=2\n\n\
	[seq-write]\nrw=write\nnumjobs=2\n\n\
	[rand-read]\nrw=randread\nnumjobs=4\n\n\
	[rand-write]\nrw=randwrite\nnumjobs=4\n\n
	[mixed-rw]\nrw=randrw\nrwmixread=70\nnumjobs=4\n" > benchmarks/IO/fio/config.fio
	@rm -f benchmarks/IO/fio/testfile*

fio_run:
	@fio benchmarks/IO/fio/config.fio

#configuro e installo sockperf, le parentesi sono necessarie per eseguire i comandi nella stessa shell
sockperf:
	(cd benchmarks/IO/sockperf && ./autogen.sh && ./configure && $(MAKE) && $(MAKE) install)
#avvio un test di sockperf
sockperf_run_pingpong:
	tmux new-session -d -s sockperf_server 'sockperf server -p 9000'
#attendo che il server sia pronto
	sleep 2
	sockperf ping-pong -i 127.0.0.1 -p 9000 -t 10 > $(RESULTS_DIR)/sockperf_pingpong_results.txt
	tmux kill-session -t sockperf_server

sockperf_run_throughput:
	tmux new-session -d -s sockperf_server 'sockperf server -p 9000'
#attendo che il server sia pronto
	sleep 2
	sockperf throughput -i 127.0.0.1 -p 9000 -m 1024 -t 20  --full-rtt > $(RESULTS_DIR)/sockperf_throughput_results.txt
	tmux kill-session -t sockperf_server
#
stream:
	(cd benchmarks/memory/STREAM && gcc -O -DSTREAM_ARRAY_SIZE=33554432 stream.c -o streameseguibile)

stream_run:
	@benchmarks/memory/STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt