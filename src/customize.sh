#!/system/bin/sh
# shellcheck shell=ash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager."
[ "$MAGISK_VER_CODE" -lt "24300" ]  && abort "Requires Magisk v24.3 and Above."


# define target abi
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
    abort "* Unsupported archeticture $ARCH."
    ;;
esac

download_aapt2() {
    # define uri
    wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary/${target_bin_abi}/aapt2"
    [ "$API" -ge "31" ] && \
    wgetURI="https://github.com/nivranaitsirhc/termux-aapt/raw/main/prebuilt-binary-android-12%2B/${target_bin_abi}/aapt2"

    ui_print " - Downloading $ARCH aapt2 using wget.."
    wget "$wgetURI" -O "$MODPATH/bin/aapt2" || abort " - Unable to connect. please check your network. aborting installation."
    
    # set exec permission
    chmod +x "$MODPATH/bin/aapt2"

    "$MODPATH/bin/aapt2" version || {
        abort " - Downloaded aapt2 is currupt. aborting installation."
    }
}

# create bin dir as download folder
[ ! -d "$MODPATH/bin" ] && mkdir -p "$MODPATH/bin"

# define bin path
app_bin="/data/adb/modules/dynmountx/bin"
# upgrade
if [ -d "$app_bin" ]; then
    ui_print " - Upgrade detected."
    # copy the bin aapt2 from existing install
    ui_print " - Recycle old bin"
    cp -af "$app_bin" "$MODPATH"
    # set exec permission
    chmod +x "$MODPATH/bin/aapt2"

    "$MODPATH/bin/aapt2" version || {
        ui_print " - Recycled aapt2 is currupt."
        # remove old aapt2 bin
        rm -f "$MODPATH/bin/aapt2"
        # download new aapt2
        download_aapt2
    }
else
    # download new aapt2
    download_aapt2
fi

# define internal storage path
internal_storage_dir="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$internal_storage_dir" ] && {
    ui_print " - Setting up Internal Storage directory.."
    mkdir -p "$internal_storage_dir/apps"
    touch "$internal_storage_dir/enable"
    # touch "$internal_storage_dir/debug"
    # create an example app
    ui_print " - Creating sample in $internal_storage_dir/apps"
    mkdir -p "$internal_storage_dir/apps/com.google.android.youtube"
    touch "$internal_storage_dir/apps/com.google.android.youtube/install"
    printf "DynmontX
Place your [modified] base.apk and [unmodified] original.apk (optional) in this directory.
It will be automatically loaded once youtube runs, granted that youtube is already installed if not please install youtube.

If only the base.apk is present, the module will try to bind it if-and-only-if the current installed version match.
The module will try to backup the original apk from the system so there is no need to include the original.apk" > "$internal_storage_dir/apps/com.google.android.youtube/readme.txt"
}

# set permissions
ui_print " - Setting permissions."
set_perm_recursive "$MODPATH/bin"   root root 0755 0755 u:object_r:system_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:system_file:s0
set_perm "$MODPATH/dynmount.sh"     root root 0755 u:object_r:system_file:s0
set_perm "$MODPATH/manager.sh"      root root 0755 u:object_r:system_file:s0
set_perm "$MODPATH/service.sh"      root root 0755 u:object_r:system_file:s0

# check for proccess monitor
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    MPMURL=http://github.com/HuskyDG/magisk_proc_monitor
    ui_print ""
    ui_print "* Process Monitor tool is not installed. App will only-run in boot-service."
    ui_print "* You must use third-party apps to disable persistent app updates as this app will only run every boot."
    ui_print "* Opening link to $MPMURL"
    ui_print ""
    (
        sleep 5
        am start -a android.intent.action.VIEW -d "$MPMURL" >/dev/null 2>&1
    ) &
}
