#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: fio sockperf

getresults: fio_run && sockperf_run_pingpong && sockperf_run_throughput

fio:
	(cd fio && ./configure && $(MAKE) -C fio all && $(MAKE) -C fio install)
	$(MAKE) create_fio_file

create_fio_file:
	@printf "[global]\nioengine=libaio\ndirect=1\nbs=4k\nsize=10M\nruntime=120\ngroup_reporting\nunlink=1\n\n\
	[seq-read]\nrw=read\nnumjobs=2\n\n\
	[seq-write]\nrw=write\nnumjobs=2\n\n\
	[rand-read]\nrw=randread\nnumjobs=4\n\n\
	[rand-write]\nrw=randwrite\nnumjobs=4\n\n
	[mixed-rw]\nrw=randrw\nrwmixread=70\nnumjobs=4\n" > benchmarks/IO/fio/config.fio
	@rm -f fio/testfile*

getresultsfio:
	@fio fio/config.fio > $(RESULTS_DIR)/fio_results.txt

#configuro e installo sockperf, le parentesi sono necessarie per eseguire i comandi nella stessa shell
sockperf:
	(cd sockperf && ./autogen.sh && ./configure && $(MAKE) && $(MAKE) install)
#avvio un test di sockperf
getresultssockperf_pingpong:
	tmux new-session -d -s sockperf_server 'sockperf server -p 9000'
#attendo che il server sia pronto
	sleep 2
	sockperf ping-pong -i 127.0.0.1 -p 9000 -t 10 > $(RESULTS_DIR)/sockperf_pingpong_results.txt
	tmux kill-session -t sockperf_server

getresultssockperf_throughput:
	tmux new-session -d -s sockperf_server 'sockperf server -p 9000'
#attendo che il server sia pronto
	sleep 2
	sockperf throughput -i 127.0.0.1 -p 9000 -m 1024 -t 20  --full-rtt > $(RESULTS_DIR)/sockperf_throughput_results.txt
	tmux kill-session -t sockperf_server

clean:
	$(MAKE) -C benchmarks/IO/fio clean
	$(MAKE) -C benchmarks/IO/sockperf clean
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*
clean_results:
	rm -rf $(RESULTS_DIR)/*
