#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

[ ! "$BOOTMODE" ]                   && abort "Install only via Magisk Manager"
[ "$MAGISK_VER_CODE" -lt "25000" ]  && abort "Requires Magisk v25 and Above"

sdcard_folder="/sdcard/DynamicMountManagerX"
# setup new sdcard dir
[ ! -d "$sdcard_folder" ] && {
    ui_print "* setting up sdcard folder"
    mkdir -p "$sdcard_folder/apps"
}

# set permissions
ui_print "* setting permissions.."
set_perm_recursive "$MODPATH/bin"   root root 0755 0655 u:object_r:magisk_file:s0
set_perm_recursive "$MODPATH/lib"   root root 0755 0644 u:object_r:magisk_file:s0

# check for dynmount
[ ! -d "/data/adb/modules/magisk_proc_monitor" ] && {
    ui_print "* missing Magisk Process Monitor. Please install it after this module."
}
