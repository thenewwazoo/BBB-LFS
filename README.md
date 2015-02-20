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

Boot output:
------------
```
U-Boot SPL 2014.04-00014-g47880f5 (Apr 22 2014 - 13:23:54)
reading args
spl_load_image_fat_os: error reading image args, err - -1
reading u-boot.img
reading u-boot.img


U-Boot 2014.04-00014-g47880f5 (Apr 22 2014 - 13:23:54)

I2C:   ready
DRAM:  512 MiB
NAND:  0 MiB
MMC:   OMAP SD/MMC: 0, OMAP SD/MMC: 1
*** Warning - readenv() failed, using default environment

Net:   <ethaddr> not set. Validating first E-fuse MAC
cpsw, usb_ether
Hit any key to stop autoboot:  0
gpio: pin 53 (gpio 53) value is 1
mmc0 is current device
gpio: pin 54 (gpio 54) value is 1
SD/MMC found on device 0
reading uEnv.txt
271 bytes read in 5 ms (52.7 KiB/s)
gpio: pin 55 (gpio 55) value is 1
Loaded environment from uEnv.txt
Importing environment from mmc ...
Checking if uenvcmd is set ...
gpio: pin 56 (gpio 56) value is 1
Running uenvcmd ...
reading uImage
3956640 bytes read in 221 ms (17.1 MiB/s)
reading /am335x-boneblack.dtb
32138 bytes read in 10 ms (3.1 MiB/s)
## Booting kernel from Legacy Image at 82000000 ...
   Image Name:   Linux-3.14.26-ipipe-g07d13c6-dir
   Image Type:   ARM Linux Kernel Image (uncompressed)
   Data Size:    3956576 Bytes = 3.8 MiB
   Load Address: 80008000
   Entry Point:  80008000
   Verifying Checksum ... OK
## Flattened Device Tree blob at 88000000
   Booting using the fdt blob at 0x88000000
   Loading Kernel Image ... OK
   Using Device Tree in place at 88000000, end 8800ad89

Starting kernel ...

[    0.000000] Booting Linux on physical CPU 0x0
[    0.000000] Linux version 3.14.26-ipipe-g07d13c6-dirty (root@vagrant-ubuntu-trusty-64) (gcc version 4.9.2 20140904 (prerelease) (crosstool-NG linaro-1.13.1-4.9-2014.09 - Linaro GCC 4.9-2014.09) ) #1 Fri Feb 20 06:17:52 UTC 2015
[    0.000000] CPU: ARMv7 Processor [413fc082] revision 2 (ARMv7), cr=10c5387d
[    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT aliasing instruction cache
[    0.000000] Machine model: TI AM335x BeagleBone
[    0.000000] cma: CMA: reserved 16 MiB at 9e800000
[    0.000000] Memory policy: Data cache writeback
[    0.000000] CPU: All CPU(s) started in SVC mode.
[    0.000000] AM335X ES2.0 (sgx neon )
[    0.000000] Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 129792
[    0.000000] Kernel command line: console=ttyO0,115200n8 root=/dev/mmcblk0p2 rw rootfstype=ext3 rootwait
[    0.000000] PID hash table entries: 2048 (order: 1, 8192 bytes)
[    0.000000] Dentry cache hash table entries: 65536 (order: 6, 262144 bytes)
[    0.000000] Inode-cache hash table entries: 32768 (order: 5, 131072 bytes)
[    0.000000] Memory: 494040K/523264K available (5419K kernel code, 293K rwdata, 1824K rodata, 251K init, 351K bss, 29224K reserved, 0K highmem)
[    0.000000] Virtual kernel memory layout:
[    0.000000]     vector  : 0xffff0000 - 0xffff1000   (   4 kB)
[    0.000000]     fixmap  : 0xfff00000 - 0xfffe0000   ( 896 kB)
[    0.000000]     vmalloc : 0xe0800000 - 0xff000000   ( 488 MB)
[    0.000000]     lowmem  : 0xc0000000 - 0xe0000000   ( 512 MB)
[    0.000000]     pkmap   : 0xbfe00000 - 0xc0000000   (   2 MB)
[    0.000000]     modules : 0xbf000000 - 0xbfe00000   (  14 MB)
[    0.000000]       .text : 0xc0008000 - 0xc071b014   (7245 kB)
[    0.000000]       .init : 0xc071c000 - 0xc075ae2c   ( 252 kB)
[    0.000000]       .data : 0xc075c000 - 0xc07a57a0   ( 294 kB)
[    0.000000]        .bss : 0xc07a57a0 - 0xc07fd738   ( 352 kB)
[    0.000000] NR_IRQS:16 nr_irqs:16 16
[    0.000000] IRQ: Found an INTC at 0xfa200000 (revision 5.0) with 128 interrupts
[    0.000000] Total of 128 interrupts on 1 active controller
[    0.000000] OMAP clockevent source: timer2 at 24000000 Hz
[    0.000011] sched_clock: 32 bits at 24MHz, resolution 41ns, wraps every 178956969942ns
[    0.000028] I-pipe, 24.000 MHz clocksource, wrap in 178956 ms
[    0.000054] OMAP clocksource: timer1 at 24000000 Hz
[    0.000451] Interrupt pipeline (release #4)
[    0.000686] Console: colour dummy device 80x30
[    0.000713] Calibrating delay loop... 996.14 BogoMIPS (lpj=4980736)
[    0.089549] pid_max: default: 32768 minimum: 301
[    0.089638] Security Framework initialized
[    0.089688] Mount-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.089696] Mountpoint-cache hash table entries: 1024 (order: 0, 4096 bytes)
[    0.095688] CPU: Testing write buffer coherency: ok
[    0.096035] Setting up static identity map for 0x80550c30 - 0x80550ca0
[    0.097094] devtmpfs: initialized
[    0.098643] VFP support v0.3: implementor 41 architecture 3 part 30 variant c rev 3
[    0.105525] omap_hwmod: tptc0 using broken dt data from edma
[    0.105609] omap_hwmod: tptc1 using broken dt data from edma
[    0.105681] omap_hwmod: tptc2 using broken dt data from edma
[    0.109791] omap_hwmod: debugss: _wait_target_disable failed
[    0.164400] pinctrl core: initialized pinctrl subsystem
[    0.165333] regulator-dummy: no parameters
[    0.166890] NET: Registered protocol family 16
[    0.168587] DMA: preallocated 256 KiB pool for atomic coherent allocations
[    0.176937] syscon 44e10000.control_module: regmap [mem 0x44e10000-0x44e107fb] registered
[    0.178259] platform 49000000.edma: alias fck already exists
[    0.178281] platform 49000000.edma: alias fck already exists
[    0.178293] platform 49000000.edma: alias fck already exists
[    0.179310] OMAP GPIO hardware version 0.1
[    0.191358] No ATAGs?
[    0.191378] hw-breakpoint: debug architecture 0x4 unsupported.
[    0.211603] bio: create slab <bio-0> at 0
[    0.225138] edma-dma-engine edma-dma-engine.0: TI EDMA DMA engine driver
[    0.226035] vmmcsd_fixed: 3300 mV
[    0.228564] vgaarb: loaded
[    0.229044] i2c-core: driver [palmas] using legacy suspend method
[    0.229053] i2c-core: driver [palmas] using legacy resume method
[    0.229758] SCSI subsystem initialized
[    0.231077] usbcore: registered new interface driver usbfs
[    0.231241] usbcore: registered new interface driver hub
[    0.231423] usbcore: registered new device driver usb
[    0.232269] omap_i2c 44e0b000.i2c: could not find pctldev for node /pinmux@44e10800/pinmux_i2c0_pins, deferring probe
[    0.232292] platform 44e0b000.i2c: Driver omap_i2c requests probe deferral
[    0.232626] pps_core: LinuxPPS API ver. 1 registered
[    0.232635] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    0.232749] PTP clock support registered
[    0.234487] omap-mailbox 480c8000.mailbox: omap mailbox rev 0x400
[    0.236028] Switched to clocksource ipipe_tsc
[    0.253368] NET: Registered protocol family 2
[    0.254123] TCP established hash table entries: 4096 (order: 2, 16384 bytes)
[    0.254169] TCP bind hash table entries: 4096 (order: 2, 16384 bytes)
[    0.254208] TCP: Hash tables configured (established 4096 bind 4096)
[    0.254264] TCP: reno registered
[    0.254275] UDP hash table entries: 256 (order: 0, 4096 bytes)
[    0.254290] UDP-Lite hash table entries: 256 (order: 0, 4096 bytes)
[    0.254445] NET: Registered protocol family 1
[    0.254815] RPC: Registered named UNIX socket transport module.
[    0.254824] RPC: Registered udp transport module.
[    0.254830] RPC: Registered tcp transport module.
[    0.254835] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    0.255758] hw perfevents: enabled with ARMv7 Cortex-A8 PMU driver, 5 counters available
[    0.258269] futex hash table entries: 256 (order: -1, 3072 bytes)
[    0.376905] VFS: Disk quotas dquot_6.5.2
[    0.376964] Dquot-cache hash table entries: 1024 (order 0, 4096 bytes)
[    0.377436] NFS: Registering the id_resolver key type
[    0.377510] Key type id_resolver registered
[    0.377518] Key type id_legacy registered
[    0.377548] jffs2: version 2.2. (NAND) (SUMMARY)  © 2001-2006 Red Hat, Inc.
[    0.377696] msgmni has been set to 996
[    0.378882] NET: Registered protocol family 38
[    0.378920] io scheduler noop registered
[    0.378927] io scheduler deadline registered
[    0.378950] io scheduler cfq registered (default)
[    0.380434] pinctrl-single 44e10800.pinmux: 142 pins at pa f9e10800 size 568
[    0.383326] Serial: 8250/16550 driver, 4 ports, IRQ sharing enabled
[    0.386009] omap_uart 44e09000.serial: no wakeirq for uart0
[    0.386238] 44e09000.serial: ttyO0 at MMIO 0x44e09000 (irq = 88, base_baud = 3000000) is a OMAP UART0
[    1.019907] console [ttyO0] enabled
[    1.024834] omap_rng 48310000.rng: OMAP Random Number Generator ver. 20
[    1.041373] brd: module loaded
[    1.049538] loop: module loaded
[    1.053158] (hci_tty): inside hci_tty_init
[    1.057898] (hci_tty): allocated 249, 0
[    1.064210] mtdoops: mtd device (mtddev=name/number) must be supplied
[    1.074240] usbcore: registered new interface driver asix
[    1.080100] usbcore: registered new interface driver ax88179_178a
[    1.086644] usbcore: registered new interface driver cdc_ether
[    1.092921] usbcore: registered new interface driver smsc95xx
[    1.099059] usbcore: registered new interface driver net1080
[    1.105121] usbcore: registered new interface driver cdc_subset
[    1.111430] usbcore: registered new interface driver zaurus
[    1.117470] usbcore: registered new interface driver cdc_ncm
[    1.123809] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    1.130651] ehci-pci: EHCI PCI platform driver
[    1.135476] ehci-omap: OMAP-EHCI Host Controller driver
[    1.141368] usbcore: registered new interface driver cdc_wdm
[    1.147488] usbcore: registered new interface driver usb-storage
[    1.154692] mousedev: PS/2 mouse device common for all mice
[    1.162247] i2c-core: driver [rtc-ds1307] using legacy suspend method
[    1.169005] i2c-core: driver [rtc-ds1307] using legacy resume method
[    1.176439] omap_rtc 44e3e000.rtc: rtc core: registered 44e3e000.rtc as rtc0
[    1.184559] i2c /dev entries driver
[    1.188411] Driver for 1-wire Dallas network protocol.
[    1.195863] omap_wdt: OMAP Watchdog Timer Rev 0x01: initial timeout 60 sec
[    1.273431] mmc0: host does not support reading read-only switch. assuming write-enable.
[    1.284228] mmc0: new high speed SDHC card at address 1234
[    1.290453] ledtrig-cpu: registered to indicate activity on CPUs
[    1.297047] mmcblk0: mmc0:1234 SA04G 3.63 GiB
[    1.302146] omap-aes 53500000.aes: OMAP AES hw accel rev: 3.2
[    1.310169] omap-sham 53100000.sham: hw accel on OMAP rev 4.3
[    1.316329]  mmcblk0: p1 p2
[    1.325004] usbcore: registered new interface driver usbhid
[    1.330900] usbhid: USB HID core driver
[    1.335170] platform 44d00000.wkup_m3: Driver wkup_m3 requests probe deferral
[    1.344182] oprofile: using arm/armv7
[    1.348392] TCP: cubic registered
[    1.351892] Initializing XFRM netlink socket
[    1.356394] NET: Registered protocol family 17
[    1.361121] NET: Registered protocol family 15
[    1.366906] Key type dns_resolver registered
[    1.374520] PM: bootloader does not support rtc-only!
[    1.379925] ThumbEE CPU extension supported.
[    1.384410] Registering SWP/SWPB emulation handler
[    1.390922] regulator-dummy: disabling
[    1.398113] DCDC1: at 1500 mV
[    1.402381] vdd_mpu: 925 <--> 1375 mV at 1325 mV
[    1.407370] mmc1: BKOPS_EN bit is not set
[    1.412627] vdd_core: 925 <--> 1150 mV at 1125 mV
[    1.418424] mmc1: new high speed MMC card at address 0001
[    1.424836] mmcblk1: mmc1:0001 MMC02G 1.78 GiB
[    1.429622] LDO1: at 1800 mV
[    1.432871] mmcblk1boot0: mmc1:0001 MMC02G partition 1 1.00 MiB
[    1.439606] mmcblk1boot1: mmc1:0001 MMC02G partition 2 1.00 MiB
[    1.446233] LDO2: at 3300 mV
[    1.451015]  mmcblk1: p1 p2
[    1.454169] LDO3: 1800 mV
[    1.459017] LDO4: at 3300 mV
[    1.463051]  mmcblk1boot1: unknown partition table
[    1.468831] tps65217 0-0024: TPS65217 ID 0xe version 1.2
[    1.474416] omap_i2c 44e0b000.i2c: bus 0 rev0.11 at 400 kHz
[    1.481818]  remoteproc0: wkup_m3 is available
[    1.486541]  remoteproc0: Note: remoteproc is still under development and considered experimental.
[    1.495892]  remoteproc0: THE BINARY FORMAT IS NOT YET FINALIZED, and backward compatibility isn't yet guaranteed.
[    1.506793]  mmcblk1boot0: unknown partition table
[    1.512126]  remoteproc0: Direct firmware load failed with error -2
[    1.518710]  remoteproc0: Falling back to user helper
[    1.586090] davinci_mdio 4a101000.mdio: davinci mdio revision 1.6
[    1.592465] davinci_mdio 4a101000.mdio: detected phy mask fffffffe
[    1.599593] libphy: 4a101000.mdio: probed
[    1.603788] davinci_mdio 4a101000.mdio: phy[0]: device 4a101000.mdio:00, driver SMSC LAN8710/LAN8720
[    1.614068] cpsw 4a100000.ethernet: Detected MACID = c8:a0:30:af:05:0c
[    1.622671] omap_rtc 44e3e000.rtc: setting system clock to 2000-01-01 00:00:00 UTC (946684800)
[    2.562369] kjournald starting.  Commit interval 5 seconds
[    2.571706] EXT3-fs (mmcblk0p2): using internal journal
[    2.582032] EXT3-fs (mmcblk0p2): recovery complete
[    2.587045] EXT3-fs (mmcblk0p2): mounted filesystem with ordered data mode
[    2.594269] VFS: Mounted root (ext3 filesystem) on device 179:2.
[    2.603549] devtmpfs: mounted
[    2.607002] Freeing unused kernel memory: 248K (c071c000 - c075a000)

bbb-lfs login:
```
