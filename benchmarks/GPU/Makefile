
#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

getresults: getresultsvkmarkn getresultsFFmpeg_codificah265 && getresultsFFmpeg_decodifica
#ATTENZIONE: PER ESEGIORE FFMPEG E' NECESSARIO AVERE UN FILE input.mp4 NELLA STESSA DIRECTORY DEL MAKEFILE

all: setupgpu installvkmark install_FFmpeg 


#per glmark2 ho anche la repo https://github.com/glmark2/glmark2.git
setupgpu:
	@apt install -y meson ninja-build libx11-dev libwayland-dev libvulkan-dev \libxrandr-dev libxi-dev libegl1-mesa-dev libgles2-mesa-dev
	@apt install libglm-dev
	@apt install libassimp-dev
	@apt install libxcb-icccm4-dev wayland-protocols libdrm-dev libgbm-dev
	@apt install -y nasm
	@apt install libx264-dev
	@apt install libx265-dev
	@apt install libvpx-dev
	@apt install -y yt-dlp
	@apt install ocl-icd-opencl-dev
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

installvkmark:
	@echo "Installazione di vkmark"
	(cd vkmark && meson setup build --prefix=/usr --buildtype=release -Dxcb=true -Dwayland=false -Dkms=true --wipe )
	ninja -C vkmark/build
	sudo ninja -C vkmark/build install
	@echo "vkmark installato"


install_FFmpeg:
	(cd FFmpeg && ./configure --target-os=linux --enable-gpl --enable-libx264 --enable-libx265 --enable-libvpx && make && make install)
	@echo "FFmpeg installato"

getresultsFFmpeg_decodifica:
	@echo "Esecuzione di FFmpeg"
	ffmpeg -i output_h265.mp4 -f null - 2>&1 | grep "time=" > $(RESULTS_DIR)/ffmpeg_decodifica.txt
	rm -f output_h265.mp4


getresultsFFmpeg_codificah264:
	@echo "Esecuzione di FFmpeg"
	ffmpeg -i input.mp4 -c:v libx264 -preset fast -crf 23 output_h264.mp4 > $(RESULTS_DIR)/ffmpeg_codifica.txt

getresultsFFmpeg_codificah265:
	@echo "Esecuzione di FFmpeg"
	ffmpeg -i input.mp4 -c:v libx265 -preset fast -crf 28 output_h265.mp4 > $(RESULTS_DIR)/ffmpeg_codifica.txt

getresultsvkmark:
	vkmark > $(RESULTS_DIR)/vkmark.txt

download_4k_sample_fs:
	@echo "download sample FileSamples 720p 28s, 16 MB come input.mp4..."
	curl -L -o input.mp4 "https://filesamples.com/samples/video/mp4/sample_1280x720.mp4"

# video in 1440 https://filesamples.com/samples/video/mp4/sample_2560x1440.mp4