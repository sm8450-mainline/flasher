#!/bin/sh
# This should be run after pmbootstrap export and should be run from the kernel source dir
THISDIR=$(dirname $0)
cat .output/arch/arm64/boot/Image.gz .output/arch/arm64/boot/dts/qcom/sm8450-xiaomi-cupid.dtb > /tmp/Image.gz-dtb
mkbootimg \
    --kernel /tmp/Image.gz-dtb \
    --ramdisk /tmp/postmarketOS-export/initramfs \
    --pagesize 4096 \
    --base 0x0 \
    --kernel_offset 0x8000 \
    --ramdisk_offset 0x1000000 \
    --tags_offset 0x100 \
    --dtb_offset 0x1f00000 \
    --header_version 1 \
    --os_version 14.0.0 \
    --os_patch_level 2099-12 \
    --cmdline "earlycon clk_ignore_unused pd_ignore_unused panic=30 audit=0 loglevel=7 allow_mismatched_32bit_el0" \
    -o /tmp/boot.img

fastboot set_active b
fastboot erase vendor_boot
fastboot erase recovery
# emptydtbo.img has exactly two null bytes
fastboot flash dtbo $THISDIR/zero.bin
fastboot --disable-verity --disable-verification flash vbmeta $THISDIR/vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system $THISDIR/vbmeta_system.img
fastboot flash boot /tmp/boot.img
fastboot reboot
