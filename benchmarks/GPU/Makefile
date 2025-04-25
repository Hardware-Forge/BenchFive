
#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

getresults: getresultsglmark2 getresultsvkmarkn 
#ATTENZIONE: PER ESEGIORE FFMPEG E' NECESSARIO AVERE UN FILE input.mp4 NELLA STESSA DIRECTORY DEL MAKEFILE

all: setupgpu installvkmark install_FFmpeg getresultsFFmpeg_decodifica


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
	@libxcb1-dev
	@libxcb-icccm4-dev
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
	ffmpeg -i input.mp4 -f null - 2>&1 | grep "time=" > $(RESULTS_DIR)/ffmpeg_decodifica.txt

getresultsFFmpeg_codificah264:
	@echo "Esecuzione di FFmpeg"
	ffmpeg -i input.mp4 -c:v libx264 -preset fast -crf 23 output_h264.mp4 > $(RESULTS_DIR)/ffmpeg_codifica.txt

getresultsFFmpeg_codificah265:
	@echo "Esecuzione di FFmpeg"
	ffmpeg -i input.mp4 -c:v libx265 -preset fast -crf 28 output_h265.mp4 > $(RESULTS_DIR)/ffmpeg_codifica.txt

getresultsvkmark:
	vkmark > $(RESULTS_DIR)/vkmark.txt


install_geekbench:
	@echo "Scaricamento e installazione di Geekbench 6..."
	curl -O https://cdn.geekbench.com/Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	tar -xvzf Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	rm Geekbench-6.4.0-LinuxRISCVPreview.tar.gz
	@echo "Geekbench 6 installato nella directory corrente."

getresults_geekbench:
	@echo "Esecuzione di Geekbench 6..."
	cd Geekbench-6.4.0-LinuxRISCVPreview && ./geekbench6 > $(RESULTS_DIR)/geekbench.txt 2>&1
	@echo "Risultati di Geekbench 6 salvati in $(RESULTS_DIR)/geekbench.txt"

download_video:
	@echo "Download yt video..."
	yt-dlp --geo-bypass -o input.%(ext)s https://youtu.be/WEwgbKr5R9I?si=LnxOWp5lQzedHwq6
