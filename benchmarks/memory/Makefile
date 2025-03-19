#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

all: stream

getresults: getresultsstream

stream:
	@(cd STREAM && gcc -O -DSTREAM_ARRAY_SIZE=$(DIMARR) stream.c -o streameseguibile)

getresultsstream:
	@STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt

CACHE_L3 := $(shell getconf LEVEL3_CACHE_SIZE)
DIMARR := $(shell expr $(CACHE_L3) \* 4)

cache:
	@echo "Dimensione cache L3: $(DIMARR) bytes"
clean:
	@rm -f STREAM/streameseguibile
	@rm -f $(RESULTS_DIR)/stream_results.txt
clean_results:
	@rm -f $(RESULTS_DIR)/stream_results.txt