#!/bin/bash

LINUX_PATH=$1
INSTALL_PATH=$2

DTB_PATH=$LINUX_PATH/arch/arm/boot/dts
DTB_FILE="ip31_navi_hl.dtb ip31-a1-h8lcd.dtb ip31-a1-h10lcd.dtb ip31-a1-l8lcd.dtb ip31-a1-l10lcd.dtb ip31-fbl-8lcd.dtb ip31-fbl-10lcd.dtb ip31-a0-h8lcd.dtb"
COMPOUND_DTB_IMAGE=dtb.img
DD_TOOLS=/bin/dd
REMOTE=/bin/rm

seek=0
sector=1K

#clear dtb.img
if [ -f $DTB_PATH/$COMPOUND_DTB_IMAGE ]; then
	$REMOTE $DTB_PATH/$COMPOUND_DTB_IMAGE
fi

for dtb in $DTB_FILE
do
	$DD_TOOLS if=$DTB_PATH/$dtb of=$DTB_PATH/$COMPOUND_DTB_IMAGE bs=$sector seek=$seek
	seek=$(($seek+256))
done

