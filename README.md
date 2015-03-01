When only nothing will do.
==========================

This is a tiniest-possible-Linux builder for the BeagleBone Black. The final image consists of u-boot, Linux and Busybox. That's it. It's based on [vsergeev's gist](https://gist.github.com/vsergeev/2391575).

This intentionally uses the Linux 3.2 kernel that comes with [TI EZSDK 6.0](http://software-dl.ti.com/sitara_linux/esd/AM335xSDK/06_00_00_00/index_FDS.html) because I never had success getting the AM335X's eCAP module properly interrupting in any later kernel.

This repo includes a Vagranfile that I use to provide a predictable build and development environment, but splat.sh doesn't doesn't require being run inside the Vagrant VM. It does assume root privs, though. So beware. My usual workflow is:

1. `vagrant up`
2. `vagrant ssh`
3. `sudo bash -xe /vagrant/splat.sh`
4. ^D
5. sudo dd if=sdcard.img of=/dev/rdisk2 bs=4096k

What it does:
-------------

1. Installs i386 binaries necessary for running the cross-compiler tools, kpartx for mounting partitioned device images (read: sdcard images), and ncurses for menuconfig
1. Downloads and makes available the Linaro cross-compiler.
1. Downloads the latest U-Boot and builds it. U-Boot sources also ship with the downloaded TI SDK. U-Boot runs on the BBB, so we use the cross-compiler.
1. Download and explode the TI SDK package. Silent mode is broken, so we do it interactively. Accept all defaults.
1. Using the kernel Makefile, we tell the Kconfig system to slurp in the settings contained in the am335x_evm_defconfig file (assumed tribal knowledge: it's in arch/arm/boot/configs).
1. Interactively edit the slurped-in config because I'm too lazy to package the end result.
  1. Turn off the Open Cryptographic Framework
  1. Select `Device drivers -> Maintain a devtmpfs filesystem to mount at /dev`
  1. Select `Device drivers -> Automount devtmpfs at /dev, after the kernel mounted the rootfs`
  1. Deselect the Open Cryptographic Framework (I don't need it; not having it around breaks the build, so I skip it)
1. Build the kernel and modules
1. Install the modules to the root of our BBB's new filesystem.
1. Download, cross-compile, and install BusyBox
1. Using `mknod`, create the bare minimum of special character devices needed, putting them on the new root fs.
1. Create directories that the boot process depends upon, like `/root/` and `/proc/`.
1. Create a disk image file, partition it using `fdisk`, mount the partitions using loopback.
1. Copy the contents of our root fs directory onto the actual root fs. Copy the bootloader and kernel into the actual boot fs.
1. Unmount and ship it.

Notes:
------
* It looks like U-Boot won't boot on any non-first-party BBB clone (i.e. a board without the Beagle logo). The Beaglebone Project maintains [some patches](https://github.com/beagleboard/meta-beagleboard/tree/master/common-bsp/recipes-bsp/u-boot/u-boot-denx) that will work around this. I don't use them, and instead just use my "official" board. Workarounds welcome.
