#!/bin/bash

set -eu

version="${1:-3.6.2}"
subversion="${1:-0}"

PROPFILE="foreign-twrp/ramdisk/default.prop"

setprop() {
	local key="$1"
	local value="$2"

	local file="$PROPFILE"

	# escape dots and other regex characters in key for grep/sed matching
	local key_escaped="$( printf '%s\n' "$key" | sed 's/[][()\.^$*+?{}|]/\\&/g' )"

	if grep -q "^${key_escaped}=" "$file"; then
		# replace line that starts with key
		sudo sed -i "s|^${key_escaped}=.*|${key}=${value}|" "$file"
		echo -n "replaced"
	else
		# append line if key does not exist
		printf '%s\n' "${key}=${value}" | sudo tee -a "$file" >/dev/null
		echo -n "added"
	fi
	echo ": ${key}=${value}"
}

remprop() {
	local key="$1"

	local file="$PROPFILE"

	# escape dots and other regex characters in key for grep/sed matching
	local key_escaped="$( printf '%s\n' "$key" | sed 's/[][()\.^$*+?{}|]/\\&/g' )"

	if grep -q "^${key_escaped}=" "$file"; then
		# remove line that starts with key
		sudo sed -i "/^${key_escaped}=.*/d" "$file"
		echo "removed: ${key}"
	fi
}

cd stock-recovery
cp stock-*recovery.img recovery.img
../unpackimg.sh --local recovery.img
cd ..

cd f2fs-tools
cp twrp-*.img recovery.img
../unpackimg.sh --local recovery.img
cd ..

cd foreign-twrp
cp twrp-*${version}*.img recovery.img
../unpackimg.sh --local recovery.img
cd ..

echo

#mv -vt stock-recovery/split_img/ foreign-twrp/split_img/recovery.img-cmdline

rm -f foreign-twrp/split_img/*
mv -vt foreign-twrp/split_img/ stock-recovery/split_img/*

sed -i "s|user|eng|" foreign-twrp/split_img/recovery.img-cmdline

echo

sudo rm -vf foreign-twrp/ramdisk/fstab.*
sudo rm -vf foreign-twrp/ramdisk/etc/*.fstab
sudo rm -vf foreign-twrp/ramdisk/ueventd.*.rc

sudo mv -vt foreign-twrp/ramdisk/etc/ stock-recovery/ramdisk/etc/recovery.fstab

sudo cp -vt foreign-twrp/ramdisk/etc/ resources/recovery.fstab

sudo rm -v foreign-twrp/ramdisk/default.prop
sudo rm -v foreign-twrp/ramdisk/ueventd.rc
sudo rm -v foreign-twrp/ramdisk/init.recovery.roth.rc
sudo rm -v foreign-twrp/ramdisk/init.recovery.ray_touch.rc
sudo rm -v foreign-twrp/ramdisk/init.recovery.nv_dev_board.usb.rc

sudo mv -v stock-recovery/ramdisk/prop.default foreign-twrp/ramdisk/default.prop
sudo mv -vt foreign-twrp/ramdisk/ stock-recovery/ramdisk/ueventd.rc
sudo mv -vt foreign-twrp/ramdisk/ stock-recovery/ramdisk/init.recovery.mt6580.rc
#sudo mv -vt foreign-twrp/ramdisk/ stock-recovery/ramdisk/fstab.enableswap

sudo cp -vt foreign-twrp/ramdisk/ resources/ueventd.rc

sudo mv -vt foreign-twrp/ramdisk/sbin/ f2fs-tools/ramdisk/sbin/fsck.f2fs
sudo mv -vt foreign-twrp/ramdisk/sbin/ f2fs-tools/ramdisk/sbin/mkfs.f2fs

echo

setprop ro.secure 0
setprop ro.allow.mock.location 1
setprop ro.debuggable 1
setprop ro.build.type eng
remprop ro.adb.secure
remprop ro.sys.usb.charging.only
remprop persist.sys.usb.config
setprop persist.sys.usb.config mtp,adb
remprop security.perf_harden

remprop ro.build.user
sudo sed -i "s|user|eng|" "$PROPFILE"

#setprop ro.build.user ""
setprop ro.build.user lanchon

setprop ro.build.tags test-keys
sudo sed -i "s|release[-]keys|test-keys|" "$PROPFILE"

echo

cd foreign-twrp
../repackimg.sh --local --origsize 
cd ..

filename="twrp-${version}-${subversion}-U3A_10_WIFI-lanchon.img"

cp foreign-twrp/image-new.img $filename

