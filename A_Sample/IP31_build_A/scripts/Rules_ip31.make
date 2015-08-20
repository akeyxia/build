PROJECT_DIR=/home/saic/projects/bsp
PROJECT_INSTALL_DIR=/home/saic/projects/bsp
PROJECT_SGX_DIR=/home/saic/projects/bsp

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
#IP31_CODE_DIR=/home/saic/projects/bsp/new
#IP31_CODE_DIR=/home/saic/projects/bsp/sa
IP31_CODE_DIR=/home/saic/projects/bsp/glsdk7.01
# end modify++

# For backwards compatibility
IP31_INSTALL_DIR=$(IP31_CODE_DIR)

# The directory that points to your kernel source directory.
LINUXKERNEL_INSTALL_DIR=$(IP31_INSTALL_DIR)/kernel
KERNEL_INSTALL_DIR=$(LINUXKERNEL_INSTALL_DIR)

# The directory that points to your u-boot source directory.
UBOOT_INSTALL_DIR=$(IP31_INSTALL_DIR)/u-boot

# The directory that points to the SGX kernel module sources.
SGX_KERNEL_MODULE_PATH=$(PROJECT_SGX_DIR)/external-linux-kernel-modules/omap5-sgx-ddk-linux/eurasia_km/eurasiacon/build/linux2/omap5430_linux

# Kernel/U-Boot build variables
LINUXKERNEL_BUILD_VARS = ARCH=arm CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)
UBOOT_BUILD_VARS = CROSS_COMPILE=$(CROSS_COMPILE_PREFIX)

# Where to copy the resulting executables
EXEC_DIR=/media/saic/rootfs
#EXEC_DIR=~/project/bsp/image4bt/rootfs

# Where to copy the resulting executables
UBOOT_EXEC_DIR=/media/saic
#UBOOT_EXEC_DIR=~/project/bsp/image4bt

