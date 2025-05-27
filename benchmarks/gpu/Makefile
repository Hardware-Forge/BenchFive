#---------------------------------------------------GPU Makefile------------------------------------------------

# Output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

getresults: getresults_FFmpeg_codificah265 getresults_FFmpeg_decodifica
# WARNING: TO RUN FFMPEG YOU NEED AN input.mp4 FILE IN THE SAME DIRECTORY AS THE MAKEFILE

all: setupgpu install_FFmpeg download_sample_fs

clean:
	$(MAKE) -C benchmarks/gpu/FFmpeg clean || true
	$(MAKE) -C benchmarks/gpu/vkmark clean || true
	rm -f $(RESULTS_DIR)/ffmpeg_decodifica.txt || true
	rm -f $(RESULTS_DIR)/ffmpeg_codifica.txt || true
	rm -f $(RESULTS_DIR)/vkmark.txt || true	

setupgpu:
	@apt install -y meson ninja-build libx11-dev libwayland-dev libvulkan-dev libxrandr-dev libxi-dev libegl1-mesa-dev libgles2-mesa-dev
	@apt install -y libglm-dev
	@apt install -y libassimp-dev
	@apt install -y libxcb-icccm4-dev wayland-protocols libdrm-dev libgbm-dev
	@apt install -y nasm
	@apt install -y libx264-dev
	@apt install -y libx265-dev
	@apt install -y libvpx-dev
	@apt install -y pkg-config
	@apt install -y libxcb1-dev
	@apt install -y libvulkan1 mesa-vulkan-drivers vulkan-tools
	@apt install -y libxcb-randr0-dev libxcb-cursor-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-xfixes0-dev

install_vkmark:
	(cd vkmark && meson setup build && ninja -C build)
#--enable-libvpx 
install_FFmpeg:
	(cd FFmpeg && ./configure --target-os=linux --enable-gpl --enable-libx264 --enable-libx265 && make)
	@echo "FFmpeg installed"

getresults_FFmpeg_decodifica: | $(RESULTS_DIR)
	@echo "Running FFmpeg"
	./FFmpeg/ffmpeg -i output_h265.mp4 -f null -threads 1 - 2>&1 | grep "time=" > $(RESULTS_DIR)/ffmpeg_decodifica.txt
	rm -f output_h265.mp4

getresults_FFmpeg_codificah265: | $(RESULTS_DIR)
	@echo "Running FFmpeg"
	rm -f output_h265.mp4
	./FFmpeg/ffmpeg -i input.mp4 -c:v libx265 -preset fast -crf 28 -threads 1 output_h265.mp4 2> $(RESULTS_DIR)/ffmpeg_codifica.txt

getresults_vkmark: | $(RESULTS_DIR)
	- ./vkmark/build/src/vkmark --headless --winsys kms > $(RESULTS_DIR)/vkmark.txt

download_sample_fs:
	@if [ ! -f input.mp4 ]; then \
		echo "download sample FileSamples 720p 28s, 16 MB as input.mp4..."; \
		curl -L -o input.mp4 "https://filesamples.com/samples/video/mp4/sample_1280x720.mp4"; \
	fi