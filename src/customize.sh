#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"

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
    abort "* Unknown archeticture $ARCH"
    ;;
esac
ui_print "* arch type is $target_bin_arch."

wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary/${target_bin_arch}/aapt2"
[ "$API" -ge "31" ] && \
wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary-android-12%2B/${target_bin_arch}/aapt2"

ui_print "* downloading $ARCH binaries"
wget "$wgetURI" -O "$MODPATH/bin/aapt2" || abort " failed to download $ARCH binaries"

if [ -f "$MODPATH/bin/aapt2" ];then
    chmod +x "$MODPATH/bin/aapt2"
    "$MODPATH/bin/aapt2" version || {
        abort "* downloaded binary file is currupted"
    }
else
    ui_print "* failed to download binary file."
    abort "* please check your internet connection and try again."
fi

sdcard_folder="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$sdcard_folder" ] && {
    ui_print "* setting up sdcard folder"
    mkdir -p "$sdcard_folder/apps"
    touch "$sdcard_folder/enable"
    touch "$sdcard_folder/debug"
}

# set permissions
ui_print "* setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0655 u:object_r:magisk_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:magisk_file:s0

# check for proccess monitor
[ ! -d "$MAGISKTMP/.magisk/modules/magisk_proc_monitor" ] && {
    MPMURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print "* process monitor tool is not installed"
    ui_print "* please install it from $MPMURL"
    sleep 3
    am start -a android.intent.action.VIEW -d "$MPMURL" &>/dev/null
}
