#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "24300" ]  && abort "Requires Magisk v24.3 and Above"


target_bin_abi=""
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

# check if running in Magisk Manager
# check if running min Magisk ver.
# check Arch
# check if 1st install or upgrade
# 1st install -> download aapt2 -> verify if downloaded -> fail or succeed
# upgrade -> use current aapt2 -> if fail use downloader -> verify if downlaoded -> fail or succeed

download_aapt2() {
    # define uri
    wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary/${target_bin_abi}/aapt2"
    [ "$API" -ge "31" ] && \
    wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary-android-12%2B/${target_bin_abi}/aapt2"

    ui_print " - downloading $ARCH aapt2 using wget.."
    wget "$wgetURI" -O "$MODPATH/bin/aapt2" || abort " - unable to connect. please check your network. aborting installation."
    
    # set exec permission
    chmod +x "$MODPATH/bin/aapt2"

    "$MODPATH/bin/aapt2" version || {
        abort " - downloaded aapt2 is currupt. aborting installation."
    }
}

# create bin dir as download folder
[ ! -d "$MODPATH/bin" ] && mkdir -p "$MODPATH/bin"

# upgrade
if [ -d "/data/adb/modules/dynmountx/bin" ]; then
    ui_print " - upgrade detected."
    # copy the bin aapt2 from existing install
    ui_print " - recycle old bin"
    cp -af "/data/adb/modules/dynmountx/bin" "$MODPATH"
    # set exec permission
    chmod +x "$MODPATH/bin/aapt2"

    "$MODPATH/bin/aapt2" version || {
        ui_print " - recycled aapt2 is currupt."
        # remove old aapt2 bin
        rm -f "$MODPATH/bin/aapt2"
        # use download
        download_aapt2
    }
else
    # download aapt2
    download_aapt2
fi


internal_storage_dir="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$internal_storage_dir" ] && {
    ui_print " - setting up internal storage directory.."
    mkdir -p "$internal_storage_dir/apps"
    touch "$internal_storage_dir/enable"
    # touch "$internal_storage_dir/debug"
    # create an example app
    ui_print " - creating sample in $internal_storage_dir/apps"
    mkdir -p "$internal_storage_dir/apps/com.google.android.youtube"
    touch "$internal_storage_dir/apps/com.google.android.youtube/install"
    printf "place here your original.apk (unmodified) and base.apk (modified)" > "$internal_storage_dir/apps/com.google.android.youtube/readme.txt"
}

# set permissions
ui_print " - setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0755 u:object_r:system_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:system_file:s0
set_perm "$MODPATH/manager.sh" root root 0755 u:object_r:system_file:s0
set_perm "$MODPATH/service.sh" root root 0755 u:object_r:system_file:s0

# check for proccess monitor
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    MPMURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print "* process monitor tool is not installed"
    ui_print "* opening link to $MPMURL"
    (
    sleep 5
    am start -a android.intent.action.VIEW -d "$MPMURL" &>/dev/null
    ) &
}
