include common.inc

__GLSDK_VERSION=update
#__GLSDK_VERSION: glsdk7.00, glsdk7.01, update, alpha, beta, ga, psdkla
__LOCAL_VERSION=new
#__LOCAL_VERSION: old, new
__INSTALL_DIR=dummy
#__INSTALL_DIR: media, dummy, media_dummy
__SRC_LOCATION=lan
#__SRC_LOCATION: lan, wan

PROJECT_DIR=/home/saic/projects/bsp
PROJECT_INSTALL_DIR=/home/saic/projects/bsp

# SGX directory
ifeq ($(__GLSDK_VERSION), glsdk7.00)
	PROJECT_SGX_DIR=/home/saic/projects/bsp/external-linux-kernel-modules
endif
ifeq ($(__GLSDK_VERSION), glsdk7.01)
	PROJECT_SGX_DIR=/home/saic/projects/bsp/glsdk7.01
endif
ifeq ($(__GLSDK_VERSION), update)
	PROJECT_SGX_DIR=/work/bsp/update
endif
ifeq ($(__GLSDK_VERSION), alpha)
	PROJECT_SGX_DIR=/work/bsp/alpha
endif
ifeq ($(__GLSDK_VERSION), beta)
	PROJECT_SGX_DIR=/work/bsp/beta
endif
ifeq ($(__GLSDK_VERSION), ga)
	PROJECT_SGX_DIR=/work/bsp/ga
endif
ifeq ($(__GLSDK_VERSION), psdkla)
	PROJECT_SGX_DIR=/work/bsp/psdkla
endif

# Define target platform.
ifeq ($(__GLSDK_VERSION), psdkla)
	DEFAULT_LINUXKERNEL_CONFIG=omap2plus_defconfig
else
	DEFAULT_LINUXKERNEL_CONFIG=ip31_defconfig
endif

# Cross compiler used for building linux and u-boot
# begin modify++
ifeq ($(OS_VERSION),YUNOS_60)
TOOLCHAIN_INSTALL_DIR=/work/tools/gcc-linaro-arm-linux-gnueabihf-4.9-glibc-2.20
else
TOOLCHAIN_INSTALL_DIR=/home/saic/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux
endif
# end modify++
CROSS_COMPILE_PREFIX=$(TOOLCHAIN_INSTALL_DIR)/bin/arm-linux-gnueabihf-

# The installation directory of the SDK.
# begin modify++
# IP31_CODE_DIR=$(shell pwd)/..
ifeq ($(__GLSDK_VERSION), glsdk7.00)
	ifeq ($(__LOCAL_VERSION), old)
		IP31_CODE_DIR=/home/saic/projects/bsp/new
	endif
	ifeq ($(__LOCAL_VERSION), new)
		IP31_CODE_DIR=/home/saic/projects/bsp/sa
	endif
endif
ifeq ($(__GLSDK_VERSION), glsdk7.01)
	ifeq ($(__SRC_LOCATION), lan)
		IP31_CODE_DIR=/home/saic/projects/bsp/glsdk7.01
	endif
	ifeq ($(__SRC_LOCATION), wan)
		IP31_CODE_DIR=/home/saic/projects/bsp/out/beta
	endif
endif
ifeq ($(__GLSDK_VERSION), update)
	IP31_CODE_DIR=/work/bsp/update
endif
ifeq ($(__GLSDK_VERSION), alpha)
	IP31_CODE_DIR=/work/bsp/alpha
endif
ifeq ($(__GLSDK_VERSION), beta)
	IP31_CODE_DIR=/work/bsp/beta
endif
ifeq ($(__GLSDK_VERSION), ga)
	IP31_CODE_DIR=/work/bsp/ga
endif
ifeq ($(__GLSDK_VERSION), psdkla)
	IP31_CODE_DIR=/work/bsp/psdkla
endif
# end modify++

# For backwards compatibility
IP31_INSTALL_DIR=$(IP31_CODE_DIR)

# The directory that points to your kernel source directory.
LINUXKERNEL_INSTALL_DIR=$(IP31_INSTALL_DIR)/linux
KERNEL_INSTALL_DIR=$(LINUXKERNEL_INSTALL_DIR)

# The directory that points to your u-boot source directory.
UBOOT_INSTALL_DIR=$(IP31_INSTALL_DIR)/u-boot

# The directory that points to the SGX kernel module sources.
ifeq ($(__GLSDK_VERSION), psdkla)
	SGX_KERNEL_MODULE_PATH=$(PROJECT_SGX_DIR)/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/omap_linux
else
	SGX_KERNEL_MODULE_PATH=$(PROJECT_SGX_DIR)/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/omap5430_linux
endif

# Kernel/U-Boot build variables
LINUXKERNEL_BUILD_VARS = ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)
UBOOT_BUILD_VARS = CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)

# Update Kernel build variables
LINUXKERNEL_BUILD_VARS += YUNOS_VERSION=$(OS_VERSION)

# Where to copy the resulting executables
ifeq ($(__INSTALL_DIR), media)
	EXEC_DIR=/media/saic/rootfs
	UBOOT_EXEC_DIR=/media/saic/boot
endif
ifeq ($(__INSTALL_DIR), dummy)
	EXEC_DIR=/home/saic/projects/bsp/INSTALL/install/dra7xx/rootfs
	UBOOT_EXEC_DIR=/home/saic/projects/bsp/INSTALL/install/dra7xx/boot
endif
ifeq ($(__INSTALL_DIR), media_dummy)
	EXEC_DIR=/media/saic/rootfs/install/dra7xx/rootfs
	UBOOT_EXEC_DIR=/media/saic/boot/install/dra7xx/boot
endif

MLO_RAW_HEADER="data/EMMC_raw_header.dat"
MLO_FINAL_IMAGE="data/MLO.raw"
DTB_A0H=ip31_navi_hl
DTB_A1H8LCD=ip31-a1-h8lcd
DTB_A1H10LCD=ip31-a1-h10lcd
DTB_A1L8LCD=ip31-a1-l8lcd
DTB_A1L10LCD=ip31-a1-l10lcd
DTB_FBL_8LCD=ip31-fbl-8lcd
DTB_FBL_10LCD=ip31-fbl-10lcd
DTB_FBL_10LCD=ip31-fbl-10lcd
DTB_A0H8LCD=ip31-a0-h8lcd
DTB_FILES=ip31_navi_hl.dtb ip31-a1-h8lcd.dtb ip31-a1-h10lcd.dtb ip31-a1-l8lcd.dtb ip31-a1-l10lcd.dtb ip31-fbl-8lcd.dtb ip31-fbl-10lcd.dtb ip31-a0-h8lcd.dtb zxq_common.dtb
COMPOUND_DTB_IMAGE=dtb.img
__USE_DTB_IMG_MK_SHELL=1
