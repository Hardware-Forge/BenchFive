#---------------------------------------------------memory Makefile------------------------------------------------

.PHONY: tinymembench ramspeed 

RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: stream tinymembench ramspeed 

getresults: getresults_stream getresults_tinymembench getresults_ramspeed

clean:
	@rm -f STREAM/streameseguibile
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@(cd tinymembench && $(MAKE) clean)
	@(cd STREAM && $(MAKE) clean)
	@rm -f $(BIN_DIR)/tinymembench
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt


clean_results:
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt
#------------------------------------------------------------stream------------------------------------------------------------
stream:
	@(cd STREAM && gcc -O -DSTREAM_ARRAY_SIZE=$(DIMARR) stream.c -o streameseguibile)
	@cp STREAM/streameseguibile $(BIN_DIR)/streameseguibile

getresults_stream:
	@./STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt

CACHE_L3 := $(shell getconf LEVEL3_CACHE_SIZE)
CACHE_L2 := $(shell getconf LEVEL2_CACHE_SIZE)
DIMARR := $(shell expr $(CACHE_L3) + $(CACHE_L2) \* 4)

#------------------------------------------------------------tinymembench------------------------------------------------------------
tinymembench:
	@(cd tinymembench && $(MAKE))
	@cp tinymembench/tinymembench $(BIN_DIR)/tinymembench
getresults_tinymembench:
	@./tinymembench/tinymembench > $(RESULTS_DIR)/tinymembench_results.txt

