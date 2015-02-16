When only nothing will do.
==========================

This is a tiniest-possible-Linux builder for the BeagleBone Black. The final image consists of u-boot, Linux and Busybox. That's it. It's based on [vsergeev's gist](https://gist.github.com/vsergeev/2391575).

This intentionally uses the Linux 3.2 kernel that comes with [TI EZSDK 6.0](http://software-dl.ti.com/sitara_linux/esd/AM335xSDK/06_00_00_00/index_FDS.html) because I never had success getting the AM335X's eCAP module properly interrupting in any later kernel.

Notes:
------
* It looks like U-Boot won't boot on any non-first-party BBB clone (i.e. a board without the Beagle logo). The Beaglebone Project maintains [some patches](https://github.com/beagleboard/meta-beagleboard/tree/master/common-bsp/recipes-bsp/u-boot/u-boot-denx) that will work around this. I don't use them, and instead just use my "official" board. Workarounds welcome.
