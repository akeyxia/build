
PROJECT_DIR=/home/saic/projects/bsp/sa
PROJECT_INSTALL_DIR=/home/saic/projects/bsp

# Cross compiler used for building linux and u-boot
TOOLCHAIN_INSTALL_DIR=/home/saic/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux
CROSS_COMPILE_PREFIX=$(TOOLCHAIN_INSTALL_DIR)/bin/arm-linux-gnueabihf-


# Kernel/U-Boot build variables
LINUXKERNEL_BUILD_VARS = ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)
UBOOT_BUILD_VARS = CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)


# The directory that points to your kernel source directory.
LINUXKERNEL_SRC_DIR=$(PROJECT_DIR)/linux-p0
DEFAULT_LINUXKERNEL_CONFIG=omap2plus_defconfig

# The directory that points to your u-boot source directory.
UBOOT_SRC_DIR=$(PROJECT_DIR)/u-boot-p0
DEFAULT_UBOOT_CONFIG=dra7xx_evm_config

# The directory that points to the SGX kernel module sources.
SGX_KERNEL_MODULE_PATH=$(PROJECT_DIR)/external-linux-kernel-modules/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/omap5430_linux

# Where to copy the resulting executables
OBJ_INSTALL_DIR=$(PROJECT_INSTALL_DIR)/_install
#EXEC_DIR=$(PROJECT_DIR)/INSTALL
EXEC_DIR=/media/saic

.PHONY: ip31 kernel u-boot

ip31: kernel dtb u-boot
bsp_kernel: kernel dtb

kernel:
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) ARCH=arm $(DEFAULT_LINUXKERNEL_CONFIG)
	cd kernel; pwd ; ./scripts/kconfig/merge_config.sh -m .config ti_config_fragments/audio_display.cfg ti_config_fragments/baseport.cfg ti_config_fragments/connectivity.cfg ti_config_fragments/ipc.cfg ti_config_fragments/power.cfg ti_config_fragments/wlan.cfg ti_config_fragments/system_test.cfg ti_config_fragments/auto.cfg ti_config_fragments/radio.cfg
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) olddefconfig ARCH=arm
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) -j4 $(LINUXKERNEL_BUILD_VARS) zImage
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) $(LINUXKERNEL_BUILD_VARS) dtbs
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) $(LINUXKERNEL_BUILD_VARS) modules
	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_SRC_DIR) DISCIMAGE=$(EXEC_DIR)
	install  $(LINUXKERNEL_SRC_DIR)/arch/arm/boot/zImage $(OBJ_INSTALL_DIR)/boot
	install  $(LINUXKERNEL_SRC_DIR)/vmlinux $(OBJ_INSTALL_DIR)/boot
	install  $(LINUXKERNEL_SRC_DIR)/System.map $(OBJ_INSTALL_DIR)/boot
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) $(LINUXKERNEL_BUILD_VARS) INSTALL_MOD_PATH=$(OBJ_INSTALL_DIR)/ modules_install
	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_SRC_DIR) DISCIMAGE=$(OBJ_INSTALL_DIR) kbuild_install

dtb:
	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) $(LINUXKERNEL_BUILD_VARS) ip31.dtb
	install  $(LINUXKERNEL_SRC_DIR)/arch/arm/boot/dts/*.dtb $(OBJ_INSTALL_DIR)/boot

u-boot:
	$(MAKE) -C $(UBOOT_SRC_DIR) $(UBOOT_BUILD_VARS) $(DEFAULT_UBOOT_CONFIG)
	$(MAKE) -C $(UBOOT_SRC_DIR) -j4 $(UBOOT_BUILD_VARS)
	install	$(UBOOT_SRC_DIR)/MLO $(OBJ_INSTALL_DIR)/u-boot
	install	$(UBOOT_SRC_DIR)/u-boot.img $(OBJ_INSTALL_DIR)/u-boot

#kernel_local_install:
#	install  $(LINUXKERNEL_SRC_DIR)/arch/arm/boot/zImage $(OBJ_INSTALL_DIR)/boot
#	install  $(LINUXKERNEL_SRC_DIR)/arch/arm/boot/dts/*.dtb $(OBJ_INSTALL_DIR)/boot
#	install  $(LINUXKERNEL_SRC_DIR)/vmlinux $(OBJ_INSTALL_DIR)/boot
#	install  $(LINUXKERNEL_SRC_DIR)/System.map $(OBJ_INSTALL_DIR)/boot
#	$(MAKE) -C $(LINUXKERNEL_SRC_DIR) $(LINUXKERNEL_BUILD_VARS) INSTALL_MOD_PATH=$(OBJ_INSTALL_DIR)/ modules_install
#	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_SRC_DIR) DISCIMAGE=$(OBJ_INSTALL_DIR) kbuild_install

#u-boot_local_install:
#	install	$(UBOOT_SRC_DIR)/MLO $(OBJ_INSTALL_DIR)/u-boot
#	install	$(UBOOT_SRC_DIR)/u-boot.img $(OBJ_INSTALL_DIR)/u-boot
	

##################################################################################################################################################

ip31_install: dtb_install u-boot_install kernel_install
bsp_kernel_install: kernel_install dtb_install

dtb_install:
	sudo cp $(LINUXKERNEL_SRC_DIR)/arch/arm/boot/dts/ip31.dtb $(EXEC_DIR)/rootfs/boot

u-boot_install:
	install $(OBJ_INSTALL_DIR)/u-boot/MLO $(EXEC_DIR)/boot
	install $(OBJ_INSTALL_DIR)/u-boot/u-boot.img $(EXEC_DIR)/boot

kernel_install:
	sudo cp  $(OBJ_INSTALL_DIR)/boot/zImage $(EXEC_DIR)/rootfs/boot/zImage-3.14.31
	sudo cp -ar $(OBJ_INSTALL_DIR)/lib/* $(EXEC_DIR)/rootfs/lib

