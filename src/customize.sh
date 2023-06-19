#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "24300" ]  && abort "Requires Magisk v24.3 and Above"

target_bin_abi=arm
case "$ARCH" in
    arm)
    target_bin_abi=arm
    ;;
    arm64)
    target_bin_abi=arm64
    ;;
    x86)
    target_bin_abi=x86-64
    ;;
    i686)
    target_bin_abi=i686
    ;;
    *)
    abort "* Unsupported archeticture $ARCH"
    ;;
esac

# download latest binaries
online_bin=true

wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary/${target_bin_abi}/aapt2"
[ "$API" -ge "31" ] && \
wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary-android-12%2B/${target_bin_abi}/aapt2"

[ ! -d "$MODPATH/bin" ] && mkdir -p "$MODPATH/bin"
ui_print "- downloading $ARCH aapt2.."
wget "$wgetURI" -O "$MODPATH/bin/aapt2" || ui_print "- unable to connect. please check your network."

if [ -f "$MODPATH/bin/aapt2" ];then
    chmod +x "$MODPATH/bin/aapt2"
    "$MODPATH/bin/aapt2" version || {
        ui_print "- downloaded aapt2 is currupted."
        online_bin=false
    }
else
    ui_print "- missing downloaded aapt2 file."
    online_bin=false
fi

[ $online_bin = false ] && {
    ui_print "- using old binaries"
    cp -af "/data/adb/modules/dynmountx/bin" "$MODPATH/bin"
}

[ ! -f "$MODPATH/bin/aapt2" ] && abort "- unable to install binary files."


internal_storage_dir="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$internal_storage_dir" ] && {
    ui_print "- setting up internal storage directory.."
    mkdir -p "$internal_storage_dir/apps"
    touch "$internal_storage_dir/enable"
    # touch "$internal_storage_dir/debug"
    # create an example app
    ui_print "- creating sample in $internal_storage_dir/apps"
    mkdir -p "$internal_storage_dir/apps/com.google.android.youtube"
    touch "$internal_storage_dir/apps/com.google.android.youtube/install"
    printf "place here your original.apk (unmodified) and base.apk (modified)" > "$internal_storage_dir/apps/com.google.android.youtube/readme.txt"
}

# set permissions
ui_print "- setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0755 u:object_r:system_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:system_file:s0
set_perm "$MODPATH/manager.sh" root root 0755 u:object_r:system_file:s0
set_perm "$MODPATH/service.sh" root root 0755 u:object_r:system_file:s0

# check for proccess monitor
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    MPMURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print "* process monitor tool is not installed"
    ui_print "* opening link to $MPMURL"
    sleep 3
    am start -a android.intent.action.VIEW -d "$MPMURL" &>/dev/null
}
