
.PHONY: tinymembench ramspeed 

RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: stream tinymembench ramspeed 

getresults: getresultsstream getresults_tinymembench getresults_ramspeed  

stream:
	@(cd STREAM && gcc -O -DSTREAM_ARRAY_SIZE=$(DIMARR) stream.c -o streameseguibile)
	@cp STREAM/streameseguibile $(BIN_DIR)/streameseguibile

getresultsstream:
	@STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt

CACHE_L3 := $(shell getconf LEVEL3_CACHE_SIZE)
CACHE_L2 := $(shell getconf LEVEL2_CACHE_SIZE)
DIMARR := $(shell expr $(CACHE_L3) + $(CACHE_L2) \* 4)


#------------------------------------------------------------tinymembench------------------------------------------------------------
tinymembench:
	@(cd tinymembench && $(MAKE))
	@cp tinymembench/tinymembench $(BIN_DIR)/tinymembench
getresults_tinymembench:
	@tinymembench/tinymembench > $(RESULTS_DIR)/tinymembench_results.txt

#------------------------------------------------------------ramspeed------------------------------------------------------------
ramspeed:
	$(MAKE) -C ramspeed CFLAGS="-O3 -Wall -fomit-frame-pointer"
	@cp ramspeed/ramlat $(BIN_DIR)/ramlat
	@cp ramspeed/rambw $(BIN_DIR)/rambw
	@cp ramspeed/ramwalk $(BIN_DIR)/ramwalk	
getresults_ramspeed:
	@ramspeed/ramlat > $(RESULTS_DIR)/ramlat_results.txt
	@ramspeed/rambw > $(RESULTS_DIR)/rambw_results.txt
	@ramspeed/ramwalk > $(RESULTS_DIR)/ramwalk_results.txt




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

clean_results:
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt
	@rm -f $(RESULTS_DIR)/ramlat_results.txt