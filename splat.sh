#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
dpkg --add-architecture i386
apt-get update
apt-get install -y --force-yes libc6:i386 libstdc++6:i386 libncurses5:i386 zlib1g:i386 git libncurses5-dev kpartx

# Get and install toolchain
wget -c https://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
tar -C / -xf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
export PATH=/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH

# Get and build u-boot
git clone git://arago-project.org/git/projects/u-boot-am33x.git || true
cd u-boot-am33x
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- am335x_evm_config
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
export PATH=$PATH:$(pwd)/tools
cd ..

# Get and build Linux kernel
mkdir -p linux; cd linux
wget -c http://software-dl.ti.com/sitara_linux/esd/AM335xSDK/06_00_00_00/exports//ti-sdk-am335x-evm-06.00.00.00-Linux-x86-Install.bin
chmod +x ti-sdk-am335x-evm-06.00.00.00-Linux-x86-Install.bin
if [ ! -f setup.sh ]; then
  ./ti-sdk-am335x-evm-06.00.00.00-Linux-x86-Install.bin --mode console --prefix $(pwd)
fi
cd board-support/linux-3.2.0-psp04.06.00.11
wget -c http://arago-project.org/git/projects/?p=am33x-cm3.git\;a=blob_plain\;f=bin/am335x-pm-firmware.bin\;hb=HEAD -O firmware/am335x-pm-firmware.bin
wget -c https://www.kernel.org/pub/linux/kernel/projects/rt/3.2/older/patch-3.2-rt10.patch.bz2
bzip2 -df patch-3.2-rt10.patch.bz2
patch -p1 -N < patch-3.2-rt10.patch || true
patch -p1 < /vagrant/01-pwm-statement-fix.patch
cp /vagrant/tisdk_am335x-evm_rt_defconfig arch/arm/configs/
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- tisdk_am335x-evm_rt_defconfig 
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- EXTRA_CFLAGS=-mno-unaligned-access uImage
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- EXTRA_CFLAGS=-mno-unaligned-access modules

# Make a root fs spot and start putting things there
mkdir -p ../../../root_fs/
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- EXTRA_CFLAGS=-mno-unaligned-access INSTALL_MOD_PATH=../../../root_fs/ modules_install
cd ../../../

# Build busybox
git clone git://busybox.net/busybox.git || true
cd busybox
git checkout remotes/origin/1_23_stable
make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- defconfig
LDFLAGS="--static" make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
LDFLAGS="--static" make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 install
rsync -a _install/ ../root_fs/
cd ..

# Set up the root fs
cd root_fs/
mkdir -p dev
if [ ! -e dev/console ]; then 
  mknod dev/console c 5 1
fi
if [ ! -e dev/null ]; then 
  mknod dev/null c 1 3
fi
mkdir -p proc
mkdir -p root
mkdir -p usr/share/udhcpc
cp ../busybox/examples/udhcp/simple.script usr/share/udhcpc/default.script
cd ..

# Create SD card image
dd if=/dev/zero of=sdcard.img bs=1M count=128
fdisk -H 64 -S 32 -C $(du -b sdcard.img | awk '{print int($1/64/32/512)}') sdcard.img <<FDISK
n
p
1

+16M
t
c
a
1
n
p
2


p
w

FDISK

# Mount the sdcard image
modprobe loop
losetup /dev/loop0 sdcard.img
kpartx -av /dev/loop0
mkfs.vfat -F 16 -n "lfsboot" /dev/mapper/loop0p1
mkfs.ext3 -L "lfsroot" /dev/mapper/loop0p2
mkdir -p mnt_root
mkdir -p mnt_boot
mount /dev/mapper/loop0p1 mnt_boot
mount /dev/mapper/loop0p2 mnt_root

# Populate sdcard image
cp u-boot-am33x/MLO mnt_boot/
cp u-boot-am33x/u-boot.img mnt_boot
cp linux/board-support/linux-3.2.0-psp04.06.00.11/arch/arm/boot/uImage mnt_boot/
rsync -a root_fs/ mnt_root/
rsync -a /vagrant/etc mnt_root/
chown -R root:root mnt_root/
cat >mnt_boot/uEnv.txt <<UENV
bootargs=console=ttyO0,115200n8 root=/dev/mmcblk0p2 rw rootfstype=ext3 rootwait
bootcmd=mmc rescan ; fatload mmc 0 81000000 uImage ; bootm 81000000
uenvcmd=boot
UENV

# Close and expose the sdcard image
umount mnt_root mnt_boot
kpartx -d /dev/loop0
losetup -d /dev/loop0
cp sdcard.img /vagrant/
