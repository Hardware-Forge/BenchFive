.PHONY: 
OPENCL_INC ?= /usr/include
RESULTS_DIR := ../../results

all:
	@set -e; \
	if ldconfig -p | grep -q libcudart.so; then \
		echo "Attempting CUDA build..."; \
		(cd obpmark && ./compile_all.sh allcuda); \
	elif ldconfig -p | grep -q libOpenCL.so && test -f $(OPENCL_INC)/CL/cl.hpp; then \
		echo "Attempting OpenCL build..."; \
		(cd obpmark && ./compile_all.sh allopencl); \
	elif ldconfig -p | grep -q libhip_hcc.so; then \
		echo "Attempting HIP build..."; \
		(cd obpmark && ./compile_all.sh allhip); \
	elif ldconfig -p | grep -q libgomp.so; then \
		echo "Attempting OpenMP build..."; \
		(cd obpmark && ./compile_all.sh openmp); \
	else \
		echo "Attempting cpu build..."; \
		(cd obpmark && ./compile_all.sh cpu); \
	
	fi


1.1_image:
	(cd obpmark/scripts && ./run_1.1-image.sh)
1.2_radar:
	(cd obpmark/scripts && ./run_1.2-radar.sh)
2.1_data_compression:
	(cd obpmark/scripts && ./run_2.1-data_compression.sh)
2.2_image_compression:
	(cd obpmark/scripts && ./run_2.2-image_compression.sh)
3.1_aes_encryption:
	- (cd obpmark/scripts && ./run_3.1-aes_encryption.sh) > $(RESULTS_DIR)/obpmarktest_results.txt
run_all:
	- (cd obpmark/scripts && ./run_all.sh) > $(RESULTS_DIR)/obpmark_results.txt

clean:
	(cd obpmark && make clean)

getresults: run_all