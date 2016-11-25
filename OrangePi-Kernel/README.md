Linux Kernel for OrangePI H2(zero) boards
===================================

About
-----

The repository contains Linux kernel sources (3.4.39) adapted for OrangePI H2 boards, gcc toolchain, adapted rootfs and building scripts.

Building
--------

Kernel config files and the files specific to OPI-zero board are placed in **build** directory.

The included build script *build_linux_kernel.sh* can be used to build the kernel<br />
`./build_linux_kernel.sh [zero | clean]`

The included build script *build_uboot.sh* can be used to build the uboot<br />
`./build_uboot.sh [zero]`

**clean** as 1st parameter cleans the kernel tree and build directories<br />
or
**zero** as 1st parameter build the uImage for OPI-zero<br />

After the build the resulting kernel files (uImage and kernel modules) are placed into **build** directory.

To build **script.bin** for all OPI-zero and resolutions run:<br />
`./build_scripts [clean]`<br />
**clean** as 1st parameter cleans the scripts and logs<br />

=======================================================================================================================
Example:
1.build uboot

`./build_uboot.sh zero`

2.build kernel

`./build_linux_kernel.sh clean`
`./build_linux_kernel.sh zero`

