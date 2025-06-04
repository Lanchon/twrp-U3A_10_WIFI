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

In general, only Android 8 GSIs will boot on the TCL 8182. Newer images will hang during boot
due to an issue involving audio effects within the **Vendor** partition.

However, this issue can be sidestepped as follows:

1. The **Vendor** partition will need to be modified, so take a backup image before starting.
   Boot into TWRP and pull an image of the partition from your PC:
```
adb pull /dev/block/platform/mtk-msdc.0/11120000.msdc0/by-name/vendor vendor.img
gzip vendor.img
```

2. In TWRP, go to the **Mount** menu, clear the **Mount system partition read-only** checkbox,
   and only then mount **Vendor**.

3. Disable audio effects by setting a build property with the following command,
   making sure you run it only once:
```
adb shell "echo ro.audio.ignore_effects=1 >> /vendor/build.prop"
```

4. Unmount **Vendor** and proceed to flash your desired GSI.

