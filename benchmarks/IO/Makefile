.PHONY: all clean getresults fio sockperf getresultsfio getresultssockperf_pingpong getresultssockperf_throughput getresultsfio_cmd clean_results
#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

setupio:
	@apt install libaio1t64 libaio-dev 


all: fio create_fio_filecmd

getresults: getresultsfio_cmd

fio:
	(cd fio && ./configure && make all && make install)
	$(MAKE) create_fio_filecmd
#creo test simile a crystaldiskmark
create_fio_filecmd:
	@printf "[global]\nioengine=libaio\ndirect=1\nbs=4k\nsize=1G\nruntime=30\ngroup_reporting\niodepth=32\n\n[test]\nrw=randrw\nrwmixread=70\nnumjobs=4\nfilename=testfile\n" > fio/configcmd.fio
	@rm -f fio/testfile*

getresultsfio_cmd:
	@fio fio/configcmd.fio > $(RESULTS_DIR)/fio_resultscmd.txt

#configuro e installo sockperf, le parentesi sono necessarie per eseguire i comandi nella stessa shell
.PHONY: install_sockperf

install_sockperf:
	@echo "=== Installazione di sockperf per RISC-V ==="
	cp config.sub config.guess sockperf/config/aux/

	patch -p1 < sockperf-riscv.patch

	cd sockperf && autoreconf -fvi

	cd sockperf && ./configure --host=riscv64-unknown-linux-gnu

	cd sockperf && make
	cd sockperf && sudo make install

	@echo "sockperf installato su RISC-V"

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
	rm -f $(RESULTS_DIR)/fio_resultscmd.txt
clean_results:
	rm -r $(RESULTS_DIR)/fio_resultscmd.txt