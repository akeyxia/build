include Rules_ip31.make

.PHONY:	all clean help linux linux_clean linux_install install u-boot u-boot_clean u-boot_install

#==============================================================================
# Build everything rebuildable.
#==============================================================================
all: linux dtb u-boot

#==============================================================================
# Install everything
#==============================================================================
install: linux_install dtb_install u-boot_install

#==============================================================================
# Clean up all targets.
#==============================================================================
clean: linux_clean u-boot_clean

#==============================================================================
# A help message target.
#==============================================================================
help:
	@echo
	@echo "Available build targets are  :"
	@echo
	@echo "    linux                          : Build Linux kernel uImage and module"
	@echo "    linux_clean                    : Remove generated Linux kernel files"
	@echo "    linux_install                  : Install kernel binary and  modules"
	@echo
	@echo "    u-boot                         : Build the u-boot boot loader"
	@echo "    u-boot_clean                   : Remove generated u-boot files"
	@echo "    u-boot_install                 : Install the u-boot image"
	@echo
	@echo "    all                            : Rebuild everything"
	@echo "    clean                          : Remove all generated files"
	@echo
	@echo "    install                        : Install all the targets in "
	@echo

#==============================================================================
# Build the Linux kernel. Also, an explicit cleanup target is defined.
#==============================================================================
linux:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm $(DEFAULT_LINUXKERNEL_CONFIG)
	#cd $(LINUXKERNEL_INSTALL_DIR); pwd ; ./scripts/kconfig/merge_config.sh -m .config ip31_config/ip31.cfg 
	cd board-support/linux/; pwd ; ./scripts/kconfig/merge_config.sh -m .config ti_config_fragments/audio_display.cfg   ti_config_fragments/baseport.cfg ti_config_fragments/connectivity.cfg ti_config_fragments/ipc.cfg ti_config_fragments/  power.cfg ti_config_fragments/wlan.cfg ti_config_fragments/system_test.cfg ti_config_fragments/auto.cfg                 ti_config_fragments/radio.cfg
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) olddefconfig ARCH=arm
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) zImage
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) dra7-evm.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) modules
	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) DISCIMAGE=$(EXEC_DIR)

linux_clean:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) mrproper
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) clean

linux_install:
ifneq ($(wildcard $(EXEC_DIR)),)
	install -d $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/zImage $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/dra7-evm.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/vmlinux $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/System.map $(EXEC_DIR)/boot
	sudo $(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) INSTALL_MOD_PATH=$(EXEC_DIR) modules_install
	sudo $(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) DISCIMAGE=$(EXEC_DIR) kbuild_install
else
	$(error "No found install directory($(EXEC_DIR))!")
endif

#==============================================================================
# Build dtb[s]. Also, an explicit cleanup target is defined.
#==============================================================================
dtb:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) dra7-evm.dtb

dtb_install:
ifneq ($(wildcard $(EXEC_DIR)),)
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/dra7-evm.dtb $(EXEC_DIR)/boot
else
	$(error "No found install directory($(EXEC_DIR))!")
endif

dtbs:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) dtbs
dtbs_install:
ifneq ($(wildcard $(EXEC_DIR)),)
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/*.dtb $(EXEC_DIR)/boot
else
	$(error "No found install directory($(EXEC_DIR))!")
endif

#==============================================================================
# Build u-boot. Also, an explicit cleanup target is defined.
#==============================================================================
u-boot:
	$(MAKE) -C $(UBOOT_INSTALL_DIR) $(UBOOT_BUILD_VARS) dra7-evmconfig
	$(MAKE) -C $(UBOOT_INSTALL_DIR) $(UBOOT_BUILD_VARS)

u-boot_clean:
	$(MAKE) -C $(UBOOT_INSTALL_DIR) $(UBOOT_BUILD_VARS) distclean

u-boot_install:
ifneq ($(wildcard $(UBOOT_EXEC_DIR)),)
	install -d $(UBOOT_EXEC_DIR)
	install $(UBOOT_INSTALL_DIR)/MLO $(UBOOT_EXEC_DIR)
	install $(UBOOT_INSTALL_DIR)/u-boot.img $(UBOOT_EXEC_DIR)
	install $(UBOOT_INSTALL_DIR)/u-boot.map $(UBOOT_EXEC_DIR)
else
	$(error "No found install directory($(UBOOT_EXEC_DIR))!")
endif
