#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"
[ ! -f "$MODPATH/aapt.zip" ]        && abort "Missing included bin files"

unzip -o -q -d "$TMPDIR/aapt" "$MODPATH/aapt.zip" 

[ ! -d "$TMPDIR/aapt" ]             && abort "Unable to unzip bin files"

target_bin_arch=arm
case "$ARCH" in
    arm)
    target_bin_arch=arm
    ;;
    arm64)
    target_bin_arch=arm64
    ;;
    x86|x64)
    target_bin_arch=x86-64
    ;;
    i686)
    target_bin_arch=i686
    ;;
    *)
    abort "Unknown archeticture $ARCH"
    ;;
esac
ui_print "* detacted arch - $target_bin_arch."


path_bin_dir="$TMPDIR/aapt/aapt/$target_bin_arch"
[ "$API" -ge "31" ] && path_bin_dir="$TMPDIR/aapt/aapt12/$target_bin_arch"

# copy aapt to module bin path
cp -a "$path_bin_dir/." "$MODPATH/bin"
# remove aapt.zip
rm -rf "$MODPATH/aapt.zip"


sdcard_folder="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$sdcard_folder" ] && {
    ui_print "* setting up sdcard folder"
    mkdir -p "$sdcard_folder/apps"
}

# set permissions
ui_print "* setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0655 u:object_r:magisk_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:magisk_file:s0

# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "* missing Magisk Process Monitor. Please install it after this module."
}
