.PHONY: 
OPENCL_INC ?= /usr/include

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

clean:
	(cd obpmark && make clean)
