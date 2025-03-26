.PHONY: all clean run coremark getresultscoremark testfloat getresultstestfloat linpack getresultslinpack setupn whetstone getresultswhetstone dhrystone getresultsdhrystone run_perf getresultssbcbench download_passmark synchrobench getresultssynchrobench

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: coremark

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C linpack clean || true
	$(MAKE) -C testfloat clean || true
	$(MAKE) -C dhrystone clean || true
	$(MAKE) -C whetstone clean || true	
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*
	rm -rf "$(SOFTFLOAT_DIR)"
	rm -f $(BIN_DIR)/whetstone
	rm -f whetstone/whetstone

#qui va fatto il comando setup generale git submodule update --init --recursive


#---------------------------------------------------Integer ALU performance----------------------------------------------

coremark: 
	$(MAKE) -C coremark
	find coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;


#coreMark execution and saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"


#probabilmente questo necessita di un cross compiler perche è gia per risc v (al momento ho messo dei - per ignorare gli errori ma non va lo stesso)
dhrystone:
	-$(MAKE) -C dhrystone
	-find dhrystone -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

getresultsdhrystone: | $(RESULTS_DIR)
	@dhrystone/dhrystone > $(RESULTS_DIR)/dhrystone_results.txt
	echo "Risultati di Dhrystone salvati in $(RESULTS_DIR)/dhrystone_results.txt"


PASSMARK_URL=https://www.passmark.com/downloads/PerformanceTest_Linux_x86-64.zip

download_passmark:
	wget -O $(BIN_DIR)/PerformanceTest_Linux_x86-64.zip $(PASSMARK_URL)
	unzip -o $(BIN_DIR)/PerformanceTest_Linux_x86-64.zip -d $(BIN_DIR)
	rm $(BIN_DIR)/PerformanceTest_Linux_x86-64.zip

getresultspassmark: | $(BIN_DIR) download_passmark
	sudo chmod +x $(BIN_DIR)/PerformanceTest/pt_linux_x64
	sudo ./$(BIN_DIR)/PerformanceTest/pt_linux_x64 > $(RESULTS_DIR)/passmark_results.txt
	echo "Risultati di Passmark salvati in $(RESULTS_DIR)/passmark_results.txt"


#---------------------------------------------------Floating point performance----------------------------------------------

linpack:
	$(MAKE) -C linpack
	find linpack -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;

#linpack execution and saving the score in results
getresultslinpack: | $(RESULTS_DIR)
	@linpack/linpack > $(RESULTS_DIR)/linpack_results.txt
	echo "Risultati di Linpack salvati in $(RESULTS_DIR)/linpack_results.txt"


testfloat: 
	$(MAKE) -C testfloat/build/Linux-x86_64-GCC all
	find testfloat -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;
#nota: sui risultati di testfloat c'è una vasta scelta di funzioni vediamo poi cosa vogliamo fare (magari chiedere all'utente cosa vuole runnare), per ora ho fatto una all
getresultstestfloat: | $(RESULTS_DIR)
	@-testfloat/build/Linux-x86_64-GCC/testfloat -all1 > $(RESULTS_DIR)/testfloat_results.txt
	echo "Risultati di Testfloat salvati in $(RESULTS_DIR)/testfloat_results.txt"
#altra nota: da un errore a riga 49 ma probabilmente è perche lanciando il test il mio pc non li passa tutti quindi fornisce un erroe (ho messo @- per ignorare)

#managing testfloat dependencies
ROOT_DIR := "$(CURDIR)"

SOFTFLOAT_DIR := $(ROOT_DIR)/berkeley-softfloat-3
SOFTFLOAT_REPO := https://github.com/ucb-bar/berkeley-softfloat-3.git
SOFTFLOAT_BUILD_DIR := $(SOFTFLOAT_DIR)/build/Linux-x86_64-GCC

setup:
	@echo "Cartella di lavoro: $(ROOT_DIR)"
	@if [ ! -d "$(SOFTFLOAT_DIR)" ]; then \
		echo "Clonazione di Berkeley SoftFloat..."; \
		git clone $(SOFTFLOAT_REPO) "$(SOFTFLOAT_DIR)"; \
	else \
		echo "Berkeley SoftFloat già presente."; \
	fi
	@echo "Compilazione di Berkeley SoftFloat..."
	@mkdir -p "$(SOFTFLOAT_BUILD_DIR)"
	@cd "$(SOFTFLOAT_BUILD_DIR)" && make

whetstone: whetstone/whetstone.c | $(BIN_DIR)
	gcc -o $(BIN_DIR)/whetstone whetstone/whetstone.c -lm

#whetstone 100000 it represents tge number of loops, it can be changed
getresultswhetstone: | $(RESULTS_DIR)
	../../bin/whetstone 100000 > ../../results/whetstone_results.txt
	@echo "Risultati di Whetstone salvati in $(RESULTS_DIR)/whetstone_results.txt"


getresultssbcbench: | $(RESULTS_DIR)

	cd sbc-bench && sudo chmod +x sbc-bench.sh && sudo ./sbc-bench.sh > ../../../results/sbc_results.txt
	@echo "Risultati di sbc-bench salvati in $(RESULTS_DIR)/sbc_results.txt"



#---------------------------------------------------Branch Prediction----------------------------------------------

install_perf:
	sudo apt-get install linux-tools-common linux-tools-generic
	sudo apt update && sudo apt install -y linux-tools-common linux-tools-generic linux-tools-$(shell uname -r)

un_perf: | $(RESULTS_DIR) install_perf
	mkdir -p $(RESULTS_DIR)
	sudo perf stat -a -e branch-misses,branches sleep 5 > $(RESULTS_DIR)/perf_results.txt 2>&1
	@echo "Risultati di perf salvati in $(RESULTS_DIR)/perf_results.txt"

#2>&1 → Reindirizza sia l'output standard che gli errori nel file


#---------------------------------------------------Concurrency----------------------------------------------

#non va ancora, da sistemare....
synchrobench: | $(BIN_DIR)
	$(MAKE) -C synchrobench/c-cpp
	cp synchrobench/c-cpp $(BIN_DIR)/

getresultssynchrobench: | $(RESULTS_DIR)
	$(BIN_DIR)/synchrobench > $(RESULTS_DIR)/synchrobench_results.txt
	@echo "Risultati di synchrobench salvati in $(RESULTS_DIR)/synchrobench_results.txt"
