#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# magisk_module required
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"

MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin

MIRROR="$MAGISKTMP/.magisk/mirror"

# paramters
PROC="$1"
STAGE="$2:manager.sh"

# magisk Busybox & module local binaries
PATH="$MODDIR/bin:$PATH:$MAGISKTMP/.magisk/busybox:$PATH"


# config-static_variables 
# -----------------------
# apps folder
path_dir_storage="/sdcard/DynamicMountManagerX"
path_dir_apps_module="$MIRROR/data/adb/apps"
path_dir_apps_storage="$path_dir_storage/apps"
# tag files
path_file_tag_mounted="$path_dir_apps_module/$PROC/mounted"
path_file_tag_version_base="$path_dir_apps_module/$PROC/version_base"
path_file_tag_version_orig="$path_dir_apps_module/$PROC/version_orig"

# apk files
path_file_apk_module_base="$path_dir_apps_module/$PROC/base.apk"
path_file_apk_module_orig="$path_dir_apps_module/$PROC/original.apk"
path_file_apk_storage_base="$path_dir_apps_storage/$PROC/base.apk"
path_file_apk_storage_orig="$path_dir_apps_storage/$PROC/original.apk"

# tag files config
#path_file_tag_debug="$path_dir_apps_storage/debug"
path_file_tag_skip="$path_dir_apps_storage/$PROC/skip"
path_file_tag_force="$path_dir_apps_storage/$PROC/force"
path_file_tag_mirror="$path_dir_apps_storage/$PROC/mirror"
path_file_tag_remove="$path_dir_apps_storage/$PROC/remove"
path_file_tag_install="$path_dir_apps_storage/$PROC/install"


# dummy fn
logme(){ :; }
# source lib
[ -d "$MODDIR/lib" ] && {
    # logger
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}

# what is expected
# module 
# revanced-manager/@apps
# local/tmp/revanced-manger/@apps
# installed app /@apps

# case 1 installed==module==local   do nothing
# case 2 installed>=module==local   install module
# case 3 installed<=module==local   install module
# case 4 installed==module>=local   install local & copy local-->module
# case 5 installed==module<=local   install local & copy local-->module
# case 6 installed<>module<>local   install local & copy local-->module

# case 1 installed==module  do nothing
# case 2 installed!=module  install module

# version checking
# install   always check
# module    check-once use version file
# local     alwasy check when available


get_apk_version() {
    # 1 - variable to return
    # 2 - apk_path
    logme debug "$STAGE" "get_apk_version() -> $2" 
    [ -z "$2" ] && return 1
    if [ -n "${2##*\/*}" ]; then
        logme debug "$STAGE" "get_apk_version() -> using dumpsys"
        eval "$1=$(dumpsys package "$2" | grep versionName | cut -d= -f 2 | sed -n '1p')"
    elif [ -f "$2" ]; then
        logme debug "$STAGE" "get_apk_version() -> using aapt"
        eval "$1=$(aapt2 dump badging "$2" | grep versionName | sed -e "s/.*versionName='//" -e "s/' .*//")"
    fi
}

set_permissions() {
    chown "$2:$3" "$1"    || return 1
    chmod "$4" "$1"       || return 1
    local CON=$5
    [ -z "$CON" ] && CON=u:object_r:system_file:s0
    chcon "$CON" "$1"     || return 1
}

set_permissions_recursive() {
  find "$1" -type d 2>/dev/null | while read dir; do
    set_permissions "$dir" "$2" "$3" "$4" "$6"
  done
  find "$1" -type f -o -type l 2>/dev/null | while read file; do
    set_permissions "$file" "$2" "$3" "$5" "$6"
  done
}

bind_me() {
    logme debug "$STAGE" "bind_me() - $path_file_apk_module_base"
    logme debug "$STAGE" "bind_me() - stopping app.."
    am force-stop "$PROC"
    logme debug "$STAGE" "bind_me() - disabling app.."
    pm disable "$PROC"

    logme debug "$STAGE" "bind_me() - unmounting remants.."
    mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
        logme debug "$STAGE" "bind_me() - unmounting: $base_apk"
        umount -l "$base_apk"
    done

    logme debug "$STAGE" "bind_me() - mounting.."
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"
    mount -o bind "$path_file_apk_module_base" "$installed_path" || return 1

    logme debug "$STAGE" "bind_me() - verifying mount"
    if mount | grep -q "$installed_path";then
        logme debug "$STAGE" "bind_me() - Mounted!"
    else
        logme error "$STAGE" "bind_me() - Failed to Mount."
    fi

    logme debug "$STAGE" "bind_me() - enabling app.."
    pm enable "$PROC"
}

install_me() {
    # install apk

    logme debug "$STAGE" "install_me() - $path_file_apk_module_base"
    logme debug "$STAGE" "install_me() - stopping app.."
    am force-stop "$PROC"
    logme debug "$STAGE" "install_me() - disabling app.."
    pm disable "$PROC"

    logme debug "$STAGE" "install_me() - unmounting remants.."
    mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
        logme debug "$STAGE" "install_me() - unmounting: $base_apk"
        umount -l "$base_apk"
    done

    logme debug "$STAGE" "install_me() - installing original apk.."
    pm install -d "$path_file_apk_module_orig" || return 1

    logme debug "$STAGE" "install_me() - mounting base apk"
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"
    mount -o bind "$path_file_apk_module_base" "$installed_path" || return 1
    
    version_apk_module_base=""
    version_apk_module_orig=""
    get_apk_version version_apk_module_base "$path_file_apk_module_base"
    get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
    printf %s "$version_apk_module_base" > "$path_file_tag_version_base"
    printf %s "$version_apk_module_orig" > "$path_file_tag_version_orig"

    logme debug "$STAGE" "install_me() - verifying mount"
    if mount | grep -q "$installed_path";then
        logme debug "$STAGE" "install_me() - Mounted!"
    else
        logme error "$STAGE" "install_me() - Failed to Mount."
    fi

    logme debug "$STAGE" "install_me() - enabling app.."
    pm enable "$PROC"
}

main_normal() {
    # check if base and original apk are present
    [ ! -f "$path_file_apk_module_base" ] && {
        logme error "$STAGE" "main_normal() - $PROC - missing base.apk"
        return 1
    }

    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"

    version_apk_module_base=""
    version_apk_module_orig=""
    version_installed=""

    logme debug "$STAGE" "main_normal() - $PROC - getting versions.."

    if  [ -f "$path_file_tag_version_base" ] && \
        [ -f "$path_file_tag_version_base" ] && \
        grep '[^[:space:]]' "$path_file_tag_version_base" && \
        grep '[^[:space:]]' "$path_file_tag_version_orig"; then
        logme debug "$STAGE" "main_normal() - $PROC - using version files.."
        version_apk_module_base=$(cat "$path_file_tag_version_base")
        version_apk_module_orig=$(cat "$path_file_tag_version_orig")
    else
        logme debug "$STAGE" "main_normal() - $PROC - creating version files.."
        get_apk_version version_apk_module_base "$path_file_apk_module_base"
        get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
        printf %s "$version_apk_module_base" > "$path_file_tag_version_base"
        printf %s "$version_apk_module_orig" > "$path_file_tag_version_orig"
    fi
    
    get_apk_version version_installed "$PROC"
    
    logme debug "$STAGE" "main_normal() - $PROC - detected versions:"
    logme debug "$STAGE" "main_normal() - $PROC - installed   - $version_installed"
    logme debug "$STAGE" "main_normal() - $PROC - module_base - $version_apk_module_base"
    logme debug "$STAGE" "main_normal() - $PROC - module_orig - $version_apk_module_orig"

    # check version installed vs module
    if [ "$version_installed" != "$version_apk_module_base" ];then
        logme error "$STAGE" "main_normal() - $PROC - version mismatch: installed=$version_installed, module=$version_apk_module_base"
        # check if base.apk matches original.apk
        [ "$version_apk_module_base" != "$version_apk_module_orig" ] && {
            logme error "$STAGE" "main_normal() - $PROC - version mismatch: base=$version_apk_module_base, original=$version_apk_module_orig"
            # exit
            return 1
        }
        logme stats "$STAGE" "main_normal() - reinstalling..., calling install_me()"
        install_me
    elif [ "$version_installed" = "$version_apk_module_base" ];then
        # versions are aligned check if mounted
        if mount | grep -q "$installed_path";then
            logme stats "$STAGE" "main_normal() - already mounted."
        else
            logme stats "$STAGE" "main_normal() - not mounted..., calling bind_me()"
            bind_me
        fi
    fi
}
main() {
    logme debug "$STAGE" "main() - $PROC - processing"

    # tag files check
    # 1.  "enable" tag file must be present in internal storage directory.
    # 1.a "mirror" tag file will mirror the installed pacakges in module to internal storage.
    # 2. "package_name" dir must exist in internal storage directory.
    # recognized tag files
    # install   - install the app
    # remove    - removes the module copy
    # force     - force mount the pacakge in module dir.
    # mirror    - pacakge_name dir in module dir to internal storage dir.
    # skip      - skip mount of this pacakge_name
    [ -d "$path_dir_storage" ] && [ -f "$path_dir_storage/enable" ] && {
        logme debug "$STAGE" "main() - processing tags."
        [ ! -d "$path_dir_apps_module/$PROC" ] && mkdir -p "$path_dir_apps_module/$PROC"
        [ ! -d "$path_dir_apps_storage/$PROC" ] && mkdir -p "$path_dir_apps_storage/$PROC"
        ## tag file mode
        [ -f "$path_file_tag_mirror" ] && {
            # mirror global
            # mirror the app dir to internal directory
            logme debug "$STAGE" "main() - tag:mirror"
            rm -rf "$path_file_tag_mirror"
            cp -rf "$path_dir_apps_module" "$path_dir_storage"
        }
        [ -f "$path_file_tag_install" ] && {
            # install
            # install the package_dir
            logme debug "$STAGE" "main() - tag:install"
            rm -rf "$path_file_tag_install"
            if [ -f "$path_file_apk_storage_base" ] && [ -f "$path_file_apk_storage_orig" ]; then
                # cp to module
                logme debug "$STAGE" "main() - tag:install - copying storage to module dir"
                cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base"
                cp -rf "$path_file_apk_storage_orig" "$path_file_apk_module_orig"
                set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                install_me || return 1
                return 0
            elif [ -f "$path_file_apk_storage_base" ] && [ ! -f "$path_file_apk_storage_orig" ];then
                logme debug "$STAGE" "main() - tag:install - trying bind mode only."
                version_apk_storage_base=""
                version_installed=""
                get_apk_version version_apk_storage_base "$path_file_apk_storage_base"
                get_apk_version version_installed       "$PROC"
                if [ "$version_apk_storage_base" = "$version_installed" ];then
                    logme debug "$STAGE" "main() - tag:install - copying storage base to module dir"
                    cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base"
                    set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                    bind_me || return 1
                    return 0
                fi
                logme debug "$STAGE" "main() - tag:install - version mismatch, installed=$version_installed base=$version_apk_storage_base"
                logme error "$STAGE" "main() - tag:install - cannot proceed with bind mode due to installed apk does not match with base apk"
                return 1
            else              
                logme error "$STAGE" "main() - tag:install - failed, missing storage base or original apk."
                touch "$path_dir_apps_storage/$PROC/install_failed"
            fi
        }
        [ -f "$path_file_tag_force" ] && {
            # force
            # force mount
            logme debug "$STAGE" "main() - tag:force_mount"
            rm -rf "$path_file_tag_force"
            if [ -f "$path_file_apk_module_base" ] && [ -f "$path_file_apk_module_base" ]; then
                bind_me || return 1
                return 0
            else
                logme debug "$STAGE" "main() - tag:force_mount - failed, missing module base or original apk."
                touch "$path_dir_apps_storage/$PROC/force_mount_failed"
            fi
        }
        [ -f "$path_file_tag_skip" ] && {
            # skip
            # skip mount
            logme debug "$STAGE" "main() - tag:skip"
            logme debug "$STAGE" "main() - tag:skip - exiting.."
            return 0
        }
        [ -f "$path_file_tag_remove" ] && {
            # remove
            # remove the module package dir
            logme debug "$STAGE" "main() - tag:remove"
            rm -rf "$path_file_tag_remove"
            # unmount remnants
             mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
                logme debug "$STAGE" "main() - tag:remove - unmounting: $base_apk"
                umount -l "$base_apk"
            done
            # remove package
            rm -rf "${path_dir_apps_module:?}/$PROC" && touch "$path_dir_apps_storage/$PROC/remove_success"
            return 0
        }
    }
    # proceed with normal checks
    main_normal
}

[ ! -d "$MIRROR/data" ] && {
    logme error "$STAGE" "failed to detect mirror mount"
    return 1
}
main