# TWRP for TCL 8182 (U3A_10_WIFI)

- v3.6.2-0:
  - USB OTG and microSD card support.
  - ADB and sideloading are functional.
  - MTP is not implemented.
  - Encryption is not supported.

Note that encryption on this device is not hardware accelerated and relies on a software
implementation of AES (NEON-optimized). This results in generally low performance and high
power consumption. The keystore hardware-backed, based on a Trusty TEE implementation.

## Generic System Image (GSI) support on the TCL 8182

In general, GSIs will not boot on the TCL 8182 due to issues involving overlays and audio
effects within the **Vendor** partition.

However, these issues can be sidestepped as follows:

1. The **Vendor** partition will need to be modified, so take a backup image before starting.
   Boot into TWRP and pull an image of the partition from your PC:
```sh
adb pull /dev/block/platform/mtk-msdc.0/11120000.msdc0/by-name/vendor vendor.img
gzip vendor.img
```

2. With TWRP running, `adb shell` into the tablet from your PC, then copy and paste these
   commands as a single block:
```sh
cd /
umount /vendor

# mount /vendor R/W
mount /vendor
cd /vendor

# make backup of build.prop
cp -n build.prop build.prop.bak

# disable audio effects
sed -i '/^ro\.audio\.ignore_effects\=/d' build.prop
echo 'ro.audio.ignore_effects=1' >>build.prop

# disable overlays
mv -n overlay overlay.bak

cd /
umount /vendor

exit
```

3. Flash your desired GSI.

