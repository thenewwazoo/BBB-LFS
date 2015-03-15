#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
dpkg --add-architecture i386
apt-get update
apt-get install -y --force-yes libc6:i386 \
                               libstdc++6:i386 \
                               libncurses5:i386 \
                               zlib1g:i386 \
                               git \
                               libncurses5-dev \
                               kpartx \
                               autoconf2.13

# Get and install toolchain
wget -c https://releases.linaro.org/14.09/components/toolchain/binaries/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
tar -C / -xf gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux.tar.xz
export PATH=/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin:$PATH
export CROSS_COMPILE=arm-linux-gnueabihf-

# Get and build u-boot
git clone git://arago-project.org/git/projects/u-boot-am33x.git || true
cd u-boot-am33x
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- am335x_evm_config
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
export PATH=$PATH:$(pwd)/tools
cd ..

# Get Xenomai upstream for user-space tools
wget -c http://download.gna.org/xenomai/stable/latest/xenomai-2.6.4.tar.bz2
tar xjf xenomai-2.6.4.tar.bz2

# Get and build Linux kernel
mkdir -p linux; cd linux
wget -c http://software-dl.ti.com/sitara_linux/esd/AM335xSDK/latest/exports/am335x-evm-sdk-src-08.00.00.00.tar.gz
tar zxf am335x-evm-sdk-src-08.00.00.00.tar.gz
cd board-support/linux-3.14.26-g2489c02/
wget -c "http://arago-project.org/git/projects/?p=am33x-cm3.git;a=blob_plain;f=bin/am335x-pm-firmware.bin;hb=HEAD" -O firmware/am335x-pm-firmware.bin
patch -p1 < /vagrant/ipipe-core-3.14.26-g2489c02-arm-tiezsdk8.0.patch
cp /vagrant/tiezsdk_xenomai_defconfig arch/arm/configs/
/home/vagrant/xenomai-2.6.4/scripts/prepare-kernel.sh --arch=arm --linux=./
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- tiezsdk_xenomai_defconfig
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- LOADADDR=0x80008000 uImage
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- modules dtbs

# Make a root fs spot and start putting things there
mkdir -p ../../../root_fs/
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=../../../root_fs/ modules_install
cd ../../../

cd xenomai-2.6.4
autoconf
./configure --prefix=$(readlink -f ../root_fs/) --host=arm-linux-gnueabihf 
# Instead of altering Makefile.am, just brute-force the end result. This gives us static binaries.
find . -name Makefile -exec sed -ie 's/-lpthread -lrt/-lpthread -lrt -all-static/' {} \;
make -j4 ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-
make install
cd ..

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
  sudo mknod dev/console c 5 1
fi
if [ ! -e dev/null ]; then 
  sudo mknod dev/null c 1 3
fi
mkdir -p proc
mkdir -p root
mkdir -p usr/share/udhcpc
cp ../busybox/examples/udhcp/simple.script usr/share/udhcpc/default.script
rm -rf share/ # We don't need docs
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
sudo modprobe loop
sudo losetup /dev/loop0 sdcard.img
sudo kpartx -av /dev/loop0
sudo mkfs.vfat -F 16 -n "lfsboot" /dev/mapper/loop0p1
sudo mkfs.ext3 -L "lfsroot" /dev/mapper/loop0p2
mkdir -p mnt_root
mkdir -p mnt_boot
sudo mount /dev/mapper/loop0p1 mnt_boot
sudo mount /dev/mapper/loop0p2 mnt_root

# Populate sdcard image
sudo cp u-boot-am33x/MLO mnt_boot/
sudo cp u-boot-am33x/u-boot.img mnt_boot
sudo cp linux/board-support/linux-3.14.26-g2489c02/arch/arm/boot/uImage mnt_boot/
sudo cp linux/board-support/linux-3.14.26-g2489c02/arch/arm/boot/dts/am335x-boneblack.dtb mnt_boot/
sudo cp /vagrant/uEnv.txt mnt_boot/

sudo rsync -a root_fs/ mnt_root/
sudo rsync -a /vagrant/etc mnt_root/
sudo chown -R root:root mnt_root/

# Close and expose the sdcard image
sudo umount mnt_root mnt_boot
sudo kpartx -d /dev/loop0
sudo losetup -d /dev/loop0
cp sdcard.img /vagrant/
