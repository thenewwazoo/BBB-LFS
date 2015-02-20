When only nothing will do, right now.
=====================================

This is a tiniest-possible-Linux builder for the BeagleBone Black. The final image consists of u-boot, Linux and Busybox. That's it. It's based on [vsergeev's gist](https://gist.github.com/vsergeev/2391575).

This branch combines Xenomai 2.6.4 and the patched Linux 3.14.26 kernel included in TI's EZSDK 8.0.0 for AM335x. In order to do this, I reverted commit f8d7fca027089d003d9592177fad9e48658ec397 from TI's tree to avoid a harder-to-fix rejection, applied the Xenomai patch for 3.14.17, and fixed the remaining (minor) patch rejections:

```
$ git revert f8d7fca027089d003d9592177fad9e48658ec397
$ patch -p1 -N < ~/xenomai-2.6.4/ksrc/arch/arm/patches/ipipe-core-3.14.17-arm-4.patch
(... fix rejections ...)
$ git commit -a -m "Apply Xenomai"
$ git diff HEAD^ HEAD > ipipe-core-3.14.26-g2489c02-arm-tiezsdk8.0.patch
```

Notes:
------
* It looks like U-Boot won't boot on any non-first-party BBB clone (i.e. a board without the Beagle logo). The Beaglebone Project maintains [some patches](https://github.com/beagleboard/meta-beagleboard/tree/master/common-bsp/recipes-bsp/u-boot/u-boot-denx) that will work around this. I don't use them, and instead just use my "official" board. Workarounds welcome.
