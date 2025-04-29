.PHONY: all clean getresults fio sockperf getresultsfio getresultssockperf_pingpong getresultssockperf_throughput getresultsfio_cmd clean_results iperf3 getresultsiperf3 setupio
#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

setupio:
	@apt install libaio1t64 libaio-dev 


all: setupio fio create_fio_filecmd iperf3

getresults: getresultsfio_cmd getresultsiperf3

fio:
	(cd fio && ./configure && make all)
	@cp fio/fio $(BIN_DIR)/fio
	$(MAKE) create_fio_filecmd
#creo test simile a crystaldiskmark
create_fio_filecmd:
	@printf "[global]\nioengine=libaio\ndirect=1\nbs=4k\nsize=1G\nruntime=30\ngroup_reporting\niodepth=32\n\n[test]\nrw=randrw\nrwmixread=70\nnumjobs=4\nfilename=testfile\n" > fio/configcmd.fio
	@rm -f fio/testfile*

getresultsfio_cmd:
	@./fio/fio fio/configcmd.fio > $(RESULTS_DIR)/fio_resultscmd.txt

iperf3:
	(cd iperf3 && ./configure && make -j$(nproc))
	@cp iperf3/src/iperf3 $(BIN_DIR)/iperf3


getresultsiperf3:
	screen -dmS iperf_server ./iperf3/src/iperf3 -s && sleep 1 && screen -dmS iperf_client bash -c "./iperf3/src/iperf3 -c 127.0.0.1 -t 10 > $(RESULTS_DIR)/iperf3_results.txt"
	@sleep 10


clean:
	$(MAKE) -C benchmarks/IO/fio clean
	$(MAKE) -C benchmarks/IO/iperf3 clean
	rm -f $(RESULTS_DIR)/fio_resultscmd.txt
	rm -f $(RESULTS_DIR)/iperf3_results.txt
clean_results:
	rm -r $(RESULTS_DIR)/fio_resultscmd.txt
	rm -r $(RESULTS_DIR)/iperf3_results.txt