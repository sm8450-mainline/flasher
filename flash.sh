#!/bin/sh
# This should be run after pmbootstrap export and should be run from the kernel source dir
cat .output/arch/arm64/boot/Image.gz .output/arch/arm64/boot/dts/qcom/sm8450-xiaomi-cupid.dtb > /tmp/Image.gz-dtb
mkbootimg \
    --kernel /tmp/Image.gz-dtb \
    --ramdisk /tmp/postmarketOS-export/initramfs \
    --pagesize 4096 \
    --base 0x0 \
    --kernel_offset 0x8000 \
    --ramdisk_offset 0x1000000 \
    --tags_offset 0x100 \
    --cmdline "earlycon=tty0 console=tty0 clk_ignore_unused pd_ignore_unused" \
    --dtb_offset 0x1f00000 \
    --header_version 1 \
    --os_version 13 \
    --os_patch_level 2023-08 \
    -o /tmp/boot.img

fastboot set_active b
fastboot erase vendor_boot
fastboot erase recovery
# emptydtbo.img has exactly two null bytes
fastboot flash dtbo emptydtbo.img
fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img
fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img
fastboot flash boot /tmp/boot.img
fastboot reboot
