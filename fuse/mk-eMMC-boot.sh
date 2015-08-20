#! /bin/sh
# Script to create bootable eMMC for OMAP5/DRA7xx evm.
#
# Author: Brijesh Singh, Texas Instruments Inc.
#       : Adapted for dra7xx-evm by Nikhil Devshatwar, Texas Instruments Inc.
#       : Adapted for bootable eMMC by Alaganraj, Texas Instruments Inc.
#
# Licensed under terms of GPLv2
#

VERSION="0.1"
mmc_dev="/dev/mmcblk0"

execute ()
{
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
  echo "Script to create bootable eMMC for omap5/dra7xx evm"
  echo

  exit 0
}

usage ()
{
  echo "
Usage: `basename $1` <options> [ files for install partition ]

Mandatory options:
  --device              eMMC block device node (e.g /dev/mmcblk1)

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
    echo $main_dev | grep "$device" > /dev/null
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
    --help | -h)
      usage $0
      ;;
    --device) shift; device=$1; shift; ;;
#    --sdk) shift; sdkdir=$1; shift; ;;
    --version) version $0;;
    *) copy="$copy $1"; shift; ;;
  esac
done

#test -z $sdkdir && usage $0
test -z $device && usage $0

#if [ ! -d $sdkdir ]; then
#   echo "ERROR: $sdkdir does not exist"
#   exit 1;
#fi

if [ ! -b $device ]; then
   echo "ERROR: $device is not a block device file"
   exit 1;
fi

check_if_main_drive

echo "************************************************************"
echo "*         THIS WILL DELETE ALL THE DATA ON $device        *"
echo "*                                                          *"
echo "*         WARNING! Make sure your computer does not go     *"
echo "*                  in to idle mode while this script is    *"
echo "*                  running. The script will complete,      *"
echo "*                  but your SD card may be corrupted.      *"
echo "*                                                          *"
echo "*         Press <ENTER> to confirm....                     *"
echo "************************************************************"
read junk

for i in `ls -1 ${device}p?`; do
 echo "unmounting device '$i'"
 umount $i 2>/dev/null
done

execute "dd if=/dev/zero of=$device bs=1024 count=1024"

sync

cat << END | fdisk -H 255 -S 63 $device
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
PARTITION1=${device}1
if [ ! -b ${PARTITION1} ]; then
        PARTITION1=${device}p1
fi

PARTITION2=${device}2
if [ ! -b ${PARTITION2} ]; then
        PARTITION2=${device}p2
fi

# make partitions.
echo "Formating ${device}p1 ..."
if [ -b ${PARTITION1} ]; then
	mkfs.vfat -F 32 -n "boot" ${PARTITION1}
else
	echo "Cant find boot partition in /dev"
fi

echo "Formating ${device}p2 ..."
if [ -b ${PARITION2} ]; then
	mkfs.ext4 -L "rootfs" ${PARTITION2}
else
	echo "Cant find rootfs partition in /dev"
fi

echo "Preparing for Copy..."
execute "mkdir -p /tmp/sdk/$$/mmc_boot"
execute "mkdir -p /tmp/sdk/$$/mmc_rootfs"
execute "mkdir -p /tmp/sdk/$$/emmc_boot"
execute "mkdir -p /tmp/sdk/$$/emmc_rootfs"

execute "mount ${mmc_dev}p1 /tmp/sdk/$$/mmc_boot"
execute "mount ${mmc_dev}p2 /tmp/sdk/$$/mmc_rootfs"
execute "mount ${device}p1 /tmp/sdk/$$/emmc_boot"
execute "mount ${device}p2 /tmp/sdk/$$/emmc_rootfs"

echo "Copying boot image from ${mmc_dev}p1 to ${device}p1"
execute "cp /tmp/sdk/$$/mmc_boot/install/dra7xx/boot/u-boot.img /tmp/sdk/$$/emmc_boot/."
execute "cp /tmp/sdk/$$/mmc_boot/install/dra7xx/boot/MLO /tmp/sdk/$$/emmc_boot/."
#execute "cp /tmp/sdk/$$/mmc_boot/uenv-emmc.txt /tmp/sdk/$$/emmc_boot/uenv.txt"

echo "Extracting filesystem from ${mmc_dev}P1 to ${device}p2"
root_fs=`ls -1 /tmp/sdk/$$/mmc_boot/arago*sdk*multimedia*dra7*.tar.gz`
execute "tar zxf $root_fs -C /tmp/sdk/$$/emmc_rootfs"

echo "Copying install from ${mmc_dev}P1 to ${device}p2"
execute "cp -rvf /tmp/sdk/$$/mmc_boot/install/dra7xx/rootfs/lib /tmp/sdk/$$/emmc_rootfs/."
execute "cp -rvf /tmp/sdk/$$/mmc_boot/install/dra7xx/rootfs/boot /tmp/sdk/$$/emmc_rootfs/."

sync
echo "unmounting ${mmc_dev}p1,${mmc_dev}p2,${device}p1,${device}p2"
execute "umount /tmp/sdk/$$/mmc_boot"
execute "umount /tmp/sdk/$$/mmc_rootfs"
execute "umount /tmp/sdk/$$/emmc_boot"
execute "umount /tmp/sdk/$$/emmc_rootfs"

execute "rm -rf /tmp/sdk/$$"
echo "completed!"
