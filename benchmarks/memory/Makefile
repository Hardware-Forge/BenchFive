#---------------------------------------------------memory Makefile------------------------------------------------

.PHONY: all tinymembench stream getresults getresults_stream getresults_tinymembench clean clean_results

RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: stream tinymembench 

getresults: getresults_stream getresults_tinymembench 

clean:
	@rm -f stream/streameseguibile || true
	@rm -f $(RESULTS_DIR)/stream_results.txt || true
	@(cd tinymembench && $(MAKE) clean)
	@(cd stream && $(MAKE) clean)
	@rm -f $(BIN_DIR)/tinymembench || true
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt || true


clean_results:
	@rm -f $(RESULTS_DIR)/stream_results.txt
	@rm -f $(RESULTS_DIR)/tinymembench_results.txt
#------------------------------------------------------------stream------------------------------------------------------------
stream:
	@(cd stream && gcc -O -DSTREAM_ARRAY_SIZE=$(DIMARR) stream.c -o streameseguibile)
	@cp stream/streameseguibile $(BIN_DIR)/streameseguibile

getresults_stream:
	@./stream/streameseguibile > $(RESULTS_DIR)/stream_results.txt

CACHE_L3 := $(shell getconf LEVEL3_CACHE_SIZE)
CACHE_L2 := $(shell getconf LEVEL2_CACHE_SIZE)
DIMARR := $(shell expr $(CACHE_L3) + $(CACHE_L2) \* 4)

#------------------------------------------------------------tinymembench------------------------------------------------------------
tinymembench:
	@(cd tinymembench && $(MAKE))
	@cp tinymembench/tinymembench $(BIN_DIR)/tinymembench
getresults_tinymembench:
	@./tinymembench/tinymembench > $(RESULTS_DIR)/tinymembench_results.txt

