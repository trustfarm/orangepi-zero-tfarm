#!/bin/bash

#==========================================================
basepath=$(cd `dirname $0`; pwd)

if [ "${1}" = "" ]; then
	echo "USAGE: sudo ./build_mainline_uboot.sh zero"
	exit -1
fi

export PATH="$PWD/brandy/gcc-linaro/bin":"$PATH"
cross_comp="arm-linux-gnueabi"
echo `which arm-linux-gnueabi-gcc`

echo "check uboot source ..."
echo " "
cd $basepath/u-boot-2016.7/configs
 

config="orangepi_${1}_defconfig"
echo $config

if [ ! -f $config ]; then
	echo "source not found !"
	exit 0
fi

echo "enter u-boot source director" && cd ../
	echo "clear u-boot" && make distclean  2>&1
	echo "compile u-boot" && make $config   2>&1

date
echo "build u-boot,please wait ..." && make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabi-  2>&1
date

cd ../build/uboot
if [ -f u-boot-sunxi-with-spl.bin ]; then
	rm -rf u-boot-sunxi-with-spl.bin
fi

	echo " "
	echo $PWD
	echo " "
	cp ../../u-boot-2016.7/u-boot-sunxi-with-spl.bin ./ -rf  
	echo "****************************************Compile uboot OK***********************************"






