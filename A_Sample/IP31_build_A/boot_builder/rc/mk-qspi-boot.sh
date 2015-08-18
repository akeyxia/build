#! /bin/sh
# Script to create bootable qspi for DRA7xx evm.
#
# Author: Brijesh Singh, Texas Instruments Inc.
#       : Adapted for dra7xx-evm by Nikhil Devshatwar, Texas Instruments Inc.
#       : Adapted for bootable eMMC by Alaganraj, Texas Instruments Inc.
#       : Adapted for bootable qspi by Vinothkumar, Texas Instruments Inc.
#
# Licensed under terms of GPLv2
#

VERSION="0.1"
qspi_dev="/dev/mtd0"
emmc_dev="/dev/mmcblk0"
main_dev="/dev/mmcblk1"

execute ()
{
    echo "$*"
	$* >/dev/null
    if [ $? -ne 0 ]; then
        echo
        echo "ERROR: executing $*"
        echo
        exit 1
    fi
}

version ()
{
  echo
  echo "`basename $1` version $VERSION"
  echo "Script to create bootable qspi for dra7xx evm"
  echo

  exit 0
}

usage ()
{
  echo "
Usage: `basename $1` <options> [ files for install partition ]

Mandatory options:

--device1 - devfs entry for qspi flash as char device node
			e.g /dev/mtd

--device2 - devfs entry for eMMC flash as block device node
			e.g /dev/mmcblk1

--bootmode -'spl_early_boot' & 'two_stage_boot'
			 spl_early_boot - ROM=>SPL=>uImage
			 two_stage_boot - ROM=>SPL=>u-boot.img=>uImage

Optional options:
  --version             Print version.
  --help                Print this help message.
"
  exit 1
}

check_if_main_drive ()
{
  mount | grep " on / type " > /dev/null
  if [ "$?" != "0" ]
  then
    echo "-- WARNING: not able to determine current filesystem device"
  else
    main_dev=`mount | grep " on / type " | awk '{print $1}'`
    echo "-- Main device is: $main_dev"
    echo $main_dev | grep "$emmc_dev" > /dev/null
    [ "$?" = "0" ] && echo "++ ERROR: $device seems to be current main drive ++" && exit 1
  fi

}

echo "This has to be run on target, don't run on host"
echo "Are you running on target? (Press ENTER to continue)"
read junkdata

# Check if the script was started as root or with sudo
user=`id -u`
[ "$user" != "0" ] && echo "++ Must be root/sudo ++" && exit

# Process command line...
while [ $# -gt 0 ]; do
  case $1 in
    --help | -h)   usage $0;;
    --device1)      shift; qspi_dev=$1;echo "Dev1 is $1";;
	--device2)		shift; emmc_dev=$1;echo "Dev2 is $1";;
	--bootmode)		shift; boot_mode=$1;echo "bootmode is $1";;
    --version)     version $0;;
    *)             usage $0;;
  esac

shift

done

test -z $qspi_dev && usage $0
test -z $emmc_dev && usage $0
test -z $boot_mode && usage $0

partition=0
while [ $partition -lt 10 ]
do
	if [ ! -c $qspi_dev$partition ]; then
		echo "ERROR: $qspi_dev is not a char device file"
		exit 1;
	fi
	partition=`expr $partition + 1`
done

if [ ! -b $emmc_dev ]; then
   echo "ERROR: $emmc_dev is not a block device file"
   exit 1;
fi

check_if_main_drive

echo "************************************************************"
echo "*        THIS WILL DELETE ALL THE DATA ON flash memory     *"
echo "*                                                          *"
echo "*        WARNING! In spl_early_boot mode, qspi & eMMC      *"
echo "*        flash got erased. In two_stage_boot mode, qspi    *"
echo "*        flash got erased                                  *"
echo "*                                                          *"
echo "*        Press <ENTER> to confirm....                      *"
echo "************************************************************"
read junk

for i in `ls -1 ${emmc_dev}p?`; do
 echo "unmounting device '$i'"
 umount $i 2>/dev/null
done

umount /tmp/sdk/$$/mmc_boot 2>/dev/null
umount /tmp/sdk/$$/mmc_rootfs 2>/dev/null

main_dev=/dev/mmcblk1

# Flash the MLO, uImage & other binaries in QSPI
# Flash MLO @ 0x00000
# Flash u-boot.img @ 0x040000
# Flash dra7xx.dtb @ 0x140000
# Flash uImage @ 0x1e0000
# Flash IPU binary @ 0x9e0000

execute "mkdir -p /tmp/sdk/$$/mmc_boot"
execute "mount ${main_dev}p1 /tmp/sdk/$$/mmc_boot"

if [ "spl_early_boot" == "$boot_mode" ];then
	execute "mkdir -p /tmp/sdk/$$/mmc_rootfs"
	execute "mount ${main_dev}p2 /tmp/sdk/$$/mmc_rootfs"
fi

MLO_FILE_PATH=/tmp/sdk/$$/mmc_boot/MLO.qspi
UBOOT_FILE_PATH=/tmp/sdk/$$/mmc_boot/u-boot-qspi.img
if [ "spl_early_boot" == "$boot_mode" ];then
	DTB_FILE_PATH=/tmp/sdk/$$/mmc_boot/dra7-evm.dtb
	UIMAGE_FILE_PATH=/tmp/sdk/$$/mmc_boot/uImage
	IPU_FILE_PATH=/tmp/sdk/$$/mmc_rootfs/lib/firmware/dra7-ipu2-fw.xem4
fi

[ ! -f $MLO_FILE_PATH ] && echo "$MLO_FILE_PATH not exist" && exit 1
[ ! -f $UBOOT_FILE_PATH ] && echo "$UBOOT_FILE_PATH not exist" && exit 1
if [ "spl_early_boot" == "$boot_mode" ];then
	[ ! -f $DTB_FILE_PATH ] && echo "$DTB_FILE_PATH not exist" && exit 1
	[ ! -f $UIMAGE_FILE_PATH ] && echo "$UIMAGE_FILE_PATH not exist" && exit 1
	[ ! -f $IPU_FILE_PATH ] && echo "$IPU_FILE_PATH not exist" && exit 1
fi

# QSPI Flash chip erase
if [ "spl_early_boot" == "$boot_mode" ];then
	echo "Started qspi flash chip erase"
	execute "flash_erase -N /dev/mtd0 0 1"
	execute "flash_erase -N /dev/mtd4 0 16"
	execute "flash_erase -N /dev/mtd5 0 8"
	execute "flash_erase -N /dev/mtd8 0 128"
	execute "flash_erase -N /dev/mtd9 0 354"
	echo "Erase completed"
else
	echo "Started qspi flash block erase"
	execute "flash_erase -N /dev/mtd0 0 1"
	execute "flash_erase -N /dev/mtd4 0 16"
	echo "Erase completed"
fi

echo "Flashing MLO image @ 0x000000"
execute "mtd_debug write /dev/mtd0 0 $(ls -l $MLO_FILE_PATH | awk '{ print $5 }') $MLO_FILE_PATH"
echo "MLO flashing completed"

echo "Flashing u-boot.img image  @ 0x040000"
execute "mtd_debug write /dev/mtd4 0 $(ls -l $UBOOT_FILE_PATH | awk '{ print $5 }') $UBOOT_FILE_PATH"
echo "u-boot.img flashing completed"

if [ "two_stage_boot" == "$boot_mode" ];then
	echo "Flashing MLO & u-boot.img completed"
	execute "umount /tmp/sdk/$$/mmc_boot"
	execute "rm -rf /tmp/sdk/$$"
	echo "completed!"
	exit 0;
fi

echo "Flashing DRA7xx DTB file @ 0x140000"
execute "mtd_debug write /dev/mtd5 0 $(ls -l $DTB_FILE_PATH | awk '{ print $5 }') $DTB_FILE_PATH"
echo "DRA7xx DTB file flashing completed"

echo "Flashing uImage @ 0x1e0000"
execute "mtd_debug write /dev/mtd8 0 $(ls -l $UIMAGE_FILE_PATH | awk '{    print $5 }') $UIMAGE_FILE_PATH"
echo "uImage flashimg completed"

echo "Flashing IPU image @ 0x9e0000"
execute "mtd_debug write /dev/mtd9 0 $(ls -l $IPU_FILE_PATH | awk '{ print $5 }') $IPU_FILE_PATH"
echo "IPU image flashing completed"

execute "dd if=/dev/zero of=$emmc_dev bs=1024 count=1024"

echo "Creating Partition on eMCC"

cat << END | fdisk -H 255 -S 63 $emmc_dev
n
p
1

+64M
n
p
2


t
1
c
a
1
w
END

# handle various device names.
PARTITION1=${emmc_dev}1
if [ ! -b ${PARTITION1} ]; then
        PARTITION1=${emmc_dev}p1
fi

PARTITION2=${emmc_dev}2
if [ ! -b ${PARTITION2} ]; then
        PARTITION2=${emmc_dev}p2
fi

# make partitions.
echo "Formating ${emmc_dev}p1 ..."
if [ -b ${PARTITION1} ]; then
	mkfs.vfat -F 32 -n "boot" ${PARTITION1}
else
	echo "Cant find boot partition in /dev"
fi

echo "Formating ${emmc_dev}p2 ..."
if [ -b ${PARITION2} ]; then
	mkfs.ext4 -L "rootfs" ${PARTITION2}
else
	echo "Cant find rootfs partition in /dev"
fi

echo "Preparing for Copy..."
execute "mkdir -p /tmp/sdk/$$/emmc_rootfs"

execute "mount ${emmc_dev}p2 /tmp/sdk/$$/emmc_rootfs"

echo "Copying filesystem from ${main_dev}p2 to ${emmc_dev}p2"
execute "cp -rvf /tmp/sdk/$$/mmc_rootfs/* /tmp/sdk/$$/emmc_rootfs/."

sync
echo "unmounting ${main_dev}p1,${main_dev}p2,${emmc_dev}p2"
execute "umount /tmp/sdk/$$/mmc_rootfs"
execute "umount /tmp/sdk/$$/emmc_rootfs"
execute "umount /tmp/sdk/$$/mmc_boot"

execute "rm -rf /tmp/sdk/$$"
echo "completed!"
exit 0
