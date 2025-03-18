

all: stream

getresults: getresultsstream

stream:
	(cd STREAM && gcc -O -DSTREAM_ARRAY_SIZE=33554432 stream.c -o streameseguibile)

getresultsstream:
	@STREAM/streameseguibile > $(RESULTS_DIR)/stream_results.txt