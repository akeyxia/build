include Rules_ip31.make

.PHONY:	all clean help linux linux_user linux_clean linux_install install u-boot u-boot_clean u-boot_install

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
ifeq ($(__GLSDK_VERSION), psdkla)
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; ./scripts/kconfig/merge_config.sh -m .config ip31_config/ip31.cfg ip31_config/debug_options.cfg yunos/stub/yunos_ip31_defconfig
else
ifeq ($(BUILD_MODE), user)
	cp $(LINUXKERNEL_INSTALL_DIR)/yunos/modules/alisec/alisec_user.obj $(LINUXKERNEL_INSTALL_DIR)/yunos/modules/alisec/alisec.obj
	cp $(LINUXKERNEL_INSTALL_DIR)/yunos/modules/alitks/alitks_user.obj $(LINUXKERNEL_INSTALL_DIR)/yunos/modules/alitks/alitks.obj
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; ./scripts/kconfig/merge_config.sh -m .config yunos/stub/yunos_ip31_defconfig
else
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; git checkout yunos/modules/alisec/alisec.obj
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; git checkout yunos/modules/alitks/alitks.obj
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; ./scripts/kconfig/merge_config.sh -m .config ip31_config/debug_options.cfg yunos/stub/yunos_ip31_defconfig
endif
endif
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) olddefconfig ARCH=arm
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) zImage
#	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${IP31_BOARD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) modules PRE-BINARY=yes NEED_KALLSYM=no NEED_MULTINS=no
	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) DISCIMAGE=$(EXEC_DIR)
	date

linux_user:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) ARCH=arm $(DEFAULT_LINUXKERNEL_CONFIG)
	cd $(LINUXKERNEL_INSTALL_DIR); pwd ; ./scripts/kconfig/merge_config.sh -m .config yunos/stub/yunos_ip31_defconfig
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) olddefconfig ARCH=arm
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) zImage
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) modules PRE-BINARY=yes NEED_KALLSYM=no NEED_MULTINS=no
	$(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) DISCIMAGE=$(EXEC_DIR)
	date

linux_clean:
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) mrproper
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) distclean

linux_install:
ifneq ($(wildcard $(EXEC_DIR)),)
	install -d $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/zImage $(EXEC_DIR)/boot
#	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${IP31_BOARD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/vmlinux $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/System.map $(EXEC_DIR)/boot
ifneq ($(wildcard $(__INSTALL_DIR)), dummy)
	sudo rm $(EXEC_DIR)/lib/modules/* -rf
endif
	sudo $(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) INSTALL_MOD_PATH=$(EXEC_DIR) modules_install
	sudo $(MAKE) -C $(SGX_KERNEL_MODULE_PATH) $(LINUXKERNEL_BUILD_VARS) KERNELDIR=$(LINUXKERNEL_INSTALL_DIR) DISCIMAGE=$(EXEC_DIR) kbuild_install
ifneq ($(wildcard $(__INSTALL_DIR)), dummy)
	sudo rm $(EXEC_DIR)/lib/modules/*/build -f
	sudo rm $(EXEC_DIR)/lib/modules/*/source -f
endif
else
	$(error "No found install directory($(EXEC_DIR))!")
endif

#==============================================================================
# Build dtb[s]. Also, an explicit cleanup target is defined.
#==============================================================================
dtb:
ifeq ($(__USE_DTB_IMG_MK_SHELL),1)
	echo "building dtbs"
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_FILES}
	echo "using make dtb shell to create dtb.img"
	$(LINUXKERNEL_INSTALL_DIR)/scripts/mk-ip31-dtb-img.sh $(LINUXKERNEL_INSTALL_DIR) $(EXEC_DIR)
	#scripts/mk-ip31-dtb-img.sh $(LINUXKERNEL_INSTALL_DIR) $(EXEC_DIR)
else
#	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${IP31_BOARD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A0H}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A1H10LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A1H8LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A1L10LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A1L8LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_FBL_8LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_FBL_10LCD}.dtb
	$(MAKE) -C $(LINUXKERNEL_INSTALL_DIR) $(LINUXKERNEL_BUILD_VARS) ${DTB_A0H8LCD}.dtb
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A0H}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1H8LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=256
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1H10LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=512
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1L8LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=768
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1L10LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=1024
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_FBL_8LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=1280
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_FBL_10LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=1536
	dd if=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A0H8LCD}.dtb of=$(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) bs=1K seek=1792
endif


dtb_install:
ifneq ($(wildcard $(EXEC_DIR)),)
ifeq ($(__USE_DTB_IMG_MK_SHELL),1)
	echo "installing dtbs"
	@for dtb in ${DTB_FILES}; \
	do \
		sudo install $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$${dtb} $(EXEC_DIR)/boot; \
	done
else
#	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${IP31_BOARD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A0H}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1H8LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1H10LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1L8LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A1L10LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_FBL_8LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_FBL_10LCD}.dtb $(EXEC_DIR)/boot
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/${DTB_A0H8LCD}.dtb $(EXEC_DIR)/boot
endif	# END OF <ifeq ($(__USE_DTB_IMG_MK_SHELL),1)>
else
	$(error "No found install directory($(EXEC_DIR))!")
endif	# END OF <ifneq ($(wildcard $(EXEC_DIR)),)>
	sudo install  $(LINUXKERNEL_INSTALL_DIR)/arch/arm/boot/dts/$(COMPOUND_DTB_IMAGE) $(EXEC_DIR)/boot

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
	$(MAKE) -C $(UBOOT_INSTALL_DIR) $(UBOOT_BUILD_VARS) ${IP31_BOARD}_config
	$(MAKE) -C $(UBOOT_INSTALL_DIR) $(UBOOT_BUILD_VARS)
	date

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
