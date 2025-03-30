
.PHONY: tinymembench ramspeed likwid

RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: stream tinymembench ramspeed likwid

getresults: getresultsstream getresults_tinymembench getresults_ramspeed getresults_likwid_cachecpy getresults_likwid_cacherd

stream:
	@(cd STREAM && gcc -O -DSTREAM_ARRAY_SIZE=$(DIMARR) stream.c -o streameseguibile)

getresultsstream:
	@STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt

CACHE_L3 := $(shell getconf LEVEL3_CACHE_SIZE)
DIMARR := $(shell expr $(CACHE_L3) \* 4)

cache:
	@echo "Dimensione cache L3: $(DIMARR) bytes"


#------------------------------------------------------------tinymembench------------------------------------------------------------
tinymembench:
	@(cd tinymembench && CFLAGS="-O2 -march=atom -mtune=atom" $(MAKE))
	@cp tinymembench/tinymembench $(BIN_DIR)/tinymembench
getresults_tinymembench:
	@tinymembench/tinymembench > $(RESULTS_DIR)/tinymembench_results.txt

#------------------------------------------------------------ramspeed------------------------------------------------------------
ramspeed:
	@(cd ramspeed && $(MAKE))
	@cp ramspeed/ramlat $(BIN_DIR)/ramlat
	@cp ramspeed/rambw $(BIN_DIR)/rambw
	@cp ramspeed/ramwalk $(BIN_DIR)/ramwalk	
getresults_ramspeed:
	@ramspeed/ramlat > $(RESULTS_DIR)/ramlat_results.txt


#------------------------------------------------------------likwid------------------------------------------------------------
likwid:
	(cd likwid && $(MAKE) && $(MAKE) install)
#Copia dati nella cache (cache-to-cache bandwidth)
getresults_likwid_cachecpy:
	@likwid-bench -t clcopy -w S0:1MB > $(RESULTS_DIR)/likwid_resultscpy.txt
#Caricamento dati dalla cache (read bandwidth)
getresults_likwid_cacherd:
	@likwid-bench -t clload -w S0:1MB > $(RESULTS_DIR)/likwid_resultsrd.txt


clean:
	@rm -f STREAM/streameseguibile
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@(cd tinymembench && $(MAKE) clean)
	@rm -f $(BIN_DIR)/tinymembench
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt
	@(cd ramspeed && $(MAKE) clean)
	@rm -f $(BIN_DIR)/ramlat
	@rm -f $(BIN_DIR)/rambw
	@rm -f $(BIN_DIR)/ramwalk
	@rm -f $(RESULTS_DIR)/ramlat_results.txt
	@(cd likwid && $(MAKE) clean)
	@rm -f $(RESULTS_DIR)/likwid_resultscpy.txt
	@rm -f $(RESULTS_DIR)/likwid_resultsrd.txt

clean_results:
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt
	@rm -f $(RESULTS_DIR)/ramlat_results.txt
	@rm -f $(RESULTS_DIR)/likwid_resultscpy.txt
	@rm -f $(RESULTS_DIR)/likwid_resultsrd.txt