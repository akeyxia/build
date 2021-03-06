__GLSDK_VERSION=glsdk7.01
#__GLSDK_VERSION: glsdk7.00, glsdk7.01, update, alpha, beta, ga
__LOCAL_VERSION=new
#__LOCAL_VERSION: old, new
__INSTALL_DIR=media
#__INSTALL_DIR: media, dummy
__SRC_LOCATION=lan
#__SRC_LOCATION: lan, wan

PROJECT_DIR=/media/saic/78AA0AF3AA0AADA6/ti/glsdk/board-support
PROJECT_INSTALL_DIR=/home/saic/projects/bsp

# SGX directory
ifeq ($(__GLSDK_VERSION), glsdk7.00)
	PROJECT_SGX_DIR=/home/saic/projects/bsp/external-linux-kernel-modules
endif
ifeq ($(__GLSDK_VERSION), glsdk7.01)
#PROJECT_SGX_DIR=/home/saic/projects/bsp/glsdk7.01
	PROJECT_SGX_DIR=/media/saic/78AA0AF3AA0AADA6/ti/glsdk/board-support/external-linux-kernel-modules
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

# Define target platform.
DEFAULT_LINUXKERNEL_CONFIG=omap2plus_defconfig

# Cross compiler used for building linux and u-boot
# begin modify++
TOOLCHAIN_INSTALL_DIR=/home/saic/gcc-linaro-arm-linux-gnueabihf-4.7-2013.03-20130313_linux
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
#IP31_CODE_DIR=/home/saic/projects/bsp/glsdk7.01
	IP31_CODE_DIR=/media/saic/78AA0AF3AA0AADA6/ti/glsdk/board-support
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
# end modify++

# For backwards compatibility
IP31_INSTALL_DIR=$(IP31_CODE_DIR)

# The directory that points to your kernel source directory.
LINUXKERNEL_INSTALL_DIR=$(IP31_INSTALL_DIR)/linux
KERNEL_INSTALL_DIR=$(LINUXKERNEL_INSTALL_DIR)

# The directory that points to your u-boot source directory.
UBOOT_INSTALL_DIR=$(IP31_INSTALL_DIR)/u-boot

# The directory that points to the SGX kernel module sources.
SGX_KERNEL_MODULE_PATH=$(PROJECT_SGX_DIR)/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/omap5430_linux

# Kernel/U-Boot build variables
LINUXKERNEL_BUILD_VARS = ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)
UBOOT_BUILD_VARS = CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)

# Where to copy the resulting executables
ifeq ($(__INSTALL_DIR), media)
	EXEC_DIR=/media/saic/rootfs
	UBOOT_EXEC_DIR=/media/saic/boot
endif
ifeq ($(__INSTALL_DIR), dummy)
	EXEC_DIR=/home/saic/projects/bsp/INSTALL/install/dra7xx/rootfs
	UBOOT_EXEC_DIR=/home/saic/projects/bsp/INSTALL/install/dra7xx/boot
endif
