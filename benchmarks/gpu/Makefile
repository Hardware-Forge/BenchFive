#---------------------------------------------------GPU Makefile------------------------------------------------

#output directory
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

getresults: getresults_FFmpeg_codificah265 && getresults_FFmpeg_decodifica
#ATTENZIONE: PER ESEGUIORE FFMPEG E' NECESSARIO AVERE UN FILE input.mp4 NELLA STESSA DIRECTORY DEL MAKEFILE

all: setupgpu install_FFmpeg download_sample_fs

clean:
	$(MAKE) -C benchmarks/gpu/FFmpeg clean || true
	$(MAKE) -C benchmarks/gpu/vkmark clean || true
	rm -f $(RESULTS_DIR)/ffmpeg_decodifica.txt || true
	rm -f $(RESULTS_DIR)/ffmpeg_codifica.txt || true
	rm -f $(RESULTS_DIR)/vkmark.txt || true	

setupgpu:
	@apt install -y meson ninja-build libx11-dev libwayland-dev libvulkan-dev \libxrandr-dev libxi-dev libegl1-mesa-dev libgles2-mesa-dev
	@apt install libglm-dev
	@apt install libassimp-dev
	@apt install libxcb-icccm4-dev wayland-protocols libdrm-dev libgbm-dev
	@apt install -y nasm
	@apt install libx264-dev
	@apt install libx265-dev
	@apt install libvpx-dev
	@apt install pkg-config
	@apt install libxcb1-dev
	@apt install libxcb-icccm4-dev
	@apt install libvulkan1 mesa-vulkan-drivers vulkan-tools
	@apt install \
	  libxcb-randr0-dev \
	  libxcb-cursor-dev \
	  libxcb-keysyms1-dev \
	  libxcb-image0-dev \
	  libxcb-xfixes0-dev

install_vkmark:
	@echo "Installazione di vkmark"
	(cd vkmark && meson setup build --prefix=/usr --buildtype=release -Dxcb=true -Dwayland=false -Dkms=true --wipe )
	ninja -C vkmark/build
#	sudo ninja -C vkmark/build install
	@echo "vkmark installato"

#--enable-libvpx 
install_FFmpeg:
	(cd FFmpeg && ./configure --target-os=linux --enable-gpl --enable-libx264 --enable-libx265 && make)
	@echo "FFmpeg installato"

getresults_FFmpeg_decodifica: | $(RESULTS_DIR)
	@echo "Esecuzione di FFmpeg"
	./FFmpeg/ffmpeg -i output_h265.mp4 -f null -threads 1 - 2>&1 | grep "time=" > $(RESULTS_DIR)/ffmpeg_decodifica.txt
	rm -f output_h265.mp4

getresults_FFmpeg_codificah265: | $(RESULTS_DIR)
	@echo "Esecuzione di FFmpeg"
	./FFmpeg/ffmpeg -i input.mp4 -c:v libx265 -preset fast -crf 28 -threads 1 output_h265.mp4 2> $(RESULTS_DIR)/ffmpeg_codifica.txt

getresults_vkmark: | $(RESULTS_DIR)
	./vkmark/build/src/vkmark --winsys kms > $(RESULTS_DIR)/vkmark.txt

download_sample_fs:
	@if [ ! -f input.mp4 ]; then \
		echo "download sample FileSamples 720p 28s, 16 MB as input.mp4..."; \
		curl -L -o input.mp4 "https://filesamples.com/samples/video/mp4/sample_1280x720.mp4"; \
	fi