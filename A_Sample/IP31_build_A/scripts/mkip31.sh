#! /bin/bash

source common.inc

function helper()
{
	echo usage:
	echo "	"$0 option ip31_board ip31_target
	echo "	"option	    : build install
	echo "	"ip31_board : ip31_navi_hl ip31_navi_ll ip31_color_radio
	echo "	"ip31_target: all u-boot linux dtb/dtbs
}

if [ $# != 3 ]; then
	echo "error : less params !!!"
	helper
        exit 0
fi

IP31_OP=${1}
IP31_BOARD=${2}
IP31_TARGET=${3}

if [ $IP31_OP != build ]&&
   [ $IP31_OP != install ]; then
	echo "error : unknown option !!!"
        helper
        exit 0
fi

if [ $IP31_BOARD != ip31 ]&&
   [ $IP31_BOARD != ip31_user ]&&
   [ $IP31_BOARD != ip31_navi_hl ]&&
   [ $IP31_BOARD != ip31_navi_ll ]&&
   [ $IP31_BOARD != ip31_color_radio ]; then
	echo "error : unknown board !!!"
	helper
	exit 0
fi

if [ $IP31_TARGET != all ]&&
   [ $IP31_TARGET != u-boot ]&&
   [ $IP31_TARGET != linux ]&&
   [ $IP31_TARGET != dtb ]&&
   [ $IP31_TARGET != dtbs ]; then
	echo "error : unknown target !!!"
        helper
        exit 0
fi

CPUS=$(( $(cat /proc/cpuinfo | grep processor | tail -n 1 | cut -d":" -f 2) + 1))

case "$IP31_TARGET" in
	"all")
		BUILD_UBOOT=1
		BUILD_LINUX=1
		BUILD_DTB=1
		BUILD_DTBS=0
		;;

	"u-boot")
		BUILD_UBOOT=1
		BUILD_LINUX=0
		BUILD_DTB=0
		BUILD_DTBS=0
		;;

	"linux")
		BUILD_UBOOT=0
		BUILD_LINUX=1
		BUILD_DTB=0
		BUILD_DTBS=0
		;;
	"dtb")
		BUILD_UBOOT=0
		BUILD_LINUX=0
		BUILD_DTB=1
		BUILD_DTBS=0
		;;
	"dtbs")
		BUILD_UBOOT=0
		BUILD_LINUX=0
		BUILD_DTB=0
		BUILD_DTBS=1
		;;
esac

if [ ${BUILD_UBOOT} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
		make u-boot IP31_BOARD=${2} -j${CPUS}
		#make u-boot IP31_BOARD=ip31 -j${CPUS}
	elif [ "$IP31_OP" = "install" ]; then
		make u-boot_install IP31_BOARD=${2}
	else
		echo "error : unknown option."
	fi
fi

if [ ${BUILD_LINUX} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
		#if [ "$IP31_BOARD" == "ip31_user" ]; then
		#	make linux_user IP31_BOARD=${2} -j${CPUS}
		#else
			make linux IP31_BOARD=${2} -j${CPUS} OS_VERSION=${OS_VERSION}
		#fi
	elif [ "$IP31_OP" = "install" ]; then
		make linux_install IP31_BOARD=${2}
	else
		echo "error : unknown option."
	fi
fi

if [ ${BUILD_DTB} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
                make dtb IP31_BOARD=${2} -j${CPUS}
        elif [ "$IP31_OP" = "install" ]; then
                make dtb_install IP31_BOARD=${2}
        else 
                echo "error : unknown option."
        fi
fi

if [ ${BUILD_DTBS} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
                make dtbs -j${CPUS}
        elif [ "$IP31_OP" = "install" ]; then
                make dtbs_install
        else
                echo "error : unknown option."
        fi
fi
