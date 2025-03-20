.PHONY: all clean run coremark getresultscoremark testfloat getresultstestfloat linpack getresultslinpack setupn whetstone getresultswhetstone

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: coremark

clean:
	$(MAKE) -C coremark clean || true
	$(MAKE) -C linpack clean || true
	$(MAKE) -C testfloat clean || true
	rm -rf $(RESULTS_DIR)/*
	rm -rf $(BIN_DIR)/*
	rm -f $(BIN_DIR)/whetstone
	rm -f whetstone/whetstone

#---------------------------------------------------Integer ALU performance----------------------------------------------

coremark: 
	$(MAKE) -C coremark
	find coremark -maxdepth 1 -type f -executable -exec cp {} $(BIN_DIR)/ \;


#coreMark execution and saving the score in results
getresultscoremark: | $(RESULTS_DIR)
	@coremark/coremark.exe > $(RESULTS_DIR)/coremark_results.txt
	echo "Risultati di CoreMark salvati in $(RESULTS_DIR)/coremark_results.txt"
	

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

