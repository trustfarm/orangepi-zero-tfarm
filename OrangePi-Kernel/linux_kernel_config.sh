#!/bin/bash

# =====================================================
# After build uImage and lib are in build directory
# =====================================================

if [ "${1}" = "" ]; then
    echo "Source directory not specified."
    echo "USAGE: build_linux_kernel.sh [zero | clean]"
    exit 0
fi

export PATH="$PWD/brandy/gcc-linaro/bin":"$PATH"
cross_comp="arm-linux-gnueabi"

# ##############
# Prepare rootfs
# ##############

cd build
rm rootfs-lobo.img.gz > /dev/null 2>&1

# create new rootfs cpio
cd rootfs-test1
mkdir run > /dev/null 2>&1
mkdir -p conf/conf.d > /dev/null 2>&1
find . | cpio --quiet -o -H newc > ../rootfs-lobo.img
cd ..
gzip rootfs-lobo.img
cd ..
##=========================================================
cd linux-3.4
LINKERNEL_DIR=`pwd`

# build rootfs
rm -rf output/* > /dev/null 2>&1
mkdir -p output/lib > /dev/null 2>&1
cp ../build/rootfs-lobo.img.gz output/rootfs.cpio.gz

#==================================================================================
# ############
# Build kernel
# ############

# #################################
# change some board dependant files
cp ../build/sun8iw7p1smp_android_defconfig arch/arm/configs/sun8iw7p1smp_linux_defconfig

# ###########################
if [ "${1}" = "clean" ]; then
    make ARCH=arm CROSS_COMPILE=${cross_comp}- mrproper > /dev/null 2>&1
fi
sleep 1

if [ "${1}" = "zero" ]; then
    echo "Building kernel for OPI-Zero ..."
    echo "  Configuring ..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- sun8iw7p1smp_linux_defconfig menuconfig

    if [ $? -ne 0 ]; then
        echo "  Error: KERNEL NOT BUILT."
        exit 1
    fi
    sleep 1
fi
#==================================================================================

if [ "${1}" = "clean" ]; then
    echo "Cleaning..."
    make ARCH=arm CROSS_COMPILE=${cross_comp}- mrproper > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo "  Error."
    fi
    rm -rf ../build/lib/* > /dev/null 2>&1
    rm -f ../build/uImage* > /dev/null 2>&1
    rm -f ../kbuild* > /dev/null 2>&1
    rmdir ../build/lib > /dev/null 2>&1
    rm ../build/rootfs-lobo.img.gz > /dev/null 2>&1
    rm -rf output/* > /dev/null 2>&1
	rm -rf ../../OrangePi-BuildLinux/orange/lib/* 
fi

echo "***OK***"
