
#directory di output
RESULTS_DIR := ../../results
BIN_DIR := ../../bin

getresults: getresultsglmark2 getresultsvkmark

setupgpu:
	@apt install -y meson ninja-build libx11-dev libwayland-dev libvulkan-dev \libxrandr-dev libxi-dev libegl1-mesa-dev libgles2-mesa-dev
	@apt install libglm-dev
	@apt install libassimp-dev
	@apt install libxcb-icccm4-dev wayland-protocols libdrm-dev libgbm-dev
	@apt install glmark2


#Se stai compilando per RISC-V, assicurati di avere il cross-compiler e le librerie Vulkan disponibili.
getresultsglmark2:
	@glmark2 > $(RESULTS_DIR)/glmark2.txt

installvkmark:
	@echo "Installazione di vkmark"
	(cd vkmark && meson setup build && ninja -C build -j1 && sudo ninja -C build install)
	@echo "vkmark installato"


getresultsvkmark:
	vkmark > $(RESULTS_DIR)/glmark2.txt

