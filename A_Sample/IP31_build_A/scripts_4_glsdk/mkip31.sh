#! /bin/bash

function helper()
{
	echo usage:
	echo "	"$0 option ip31_board ip31_target
	echo "	"option	    : build install
	echo "	"ip31_board : ip31_navi_hl ip31_navi_ll ip31_color_radio
	echo "	"ip31_target: all u-boot linux dtb
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

if [ $IP31_BOARD != ip31_navi_hl ]&&
   [ $IP31_BOARD != ip31_navi_ll ]&&
   [ $IP31_BOARD != ip31_color_radio ]; then
	echo "error : unknown board !!!"
	helper
	exit 0
fi

if [ $IP31_TARGET != all ]&&
   [ $IP31_TARGET != u-boot ]&&
   [ $IP31_TARGET != linux ]&&
   [ $IP31_TARGET != dtb ]; then
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
		;;

	"u-boot")
		BUILD_UBOOT=1
		BUILD_LINUX=0
		BUILD_DTB=0
		;;

	"linux")
		BUILD_UBOOT=0
		BUILD_LINUX=1
		BUILD_DTB=0
		;;
	"dtb")
                BUILD_UBOOT=0
                BUILD_LINUX=0
                BUILD_DTB=1
                ;;
esac

if [ ${BUILD_UBOOT} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
		make u-boot IP31_BOARD=${2} -j${CPUS}
	elif [ "$IP31_OP" = "install" ]; then
		make u-boot_install IP31_BOARD=${2}
	else
		echo "error : unknown option."
	fi
fi

if [ ${BUILD_LINUX} -gt 0 ]; then
	if [ "$IP31_OP" = "build" ]; then
                make linux IP31_BOARD=${2} -j${CPUS}
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
