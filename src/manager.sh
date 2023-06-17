#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# magisk_module required
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"

MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin

MIRROR="$MAGISKTMP/.magisk/mirror"

# magisk Busybox & module local binaries
PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"

# no auto restart
noRestart=false
[ "$1" = "disableRestart" ] && noRestart=true

# config-static_variables 
# -----------------------
# apps folder
path_dir_storage="/sdcard/DynamicMountManagerX"
path_dir_apps_module="$MIRROR/data/adb/apps"
path_dir_apps_storage="$path_dir_storage/apps"
# tag files
path_file_tag_version_base="$path_dir_apps_module/$PROC/version_base"
path_file_tag_version_orig="$path_dir_apps_module/$PROC/version_orig"
path_file_tag_process="$path_dir_apps_module/$PROC/process"
# apk files
path_file_apk_module_base="$path_dir_apps_module/$PROC/base.apk"
path_file_apk_module_orig="$path_dir_apps_module/$PROC/original.apk"
path_file_apk_storage_base="$path_dir_apps_storage/$PROC/base.apk"
path_file_apk_storage_orig="$path_dir_apps_storage/$PROC/original.apk"
# tag files config
path_file_tag_global_debug="$path_dir_storage/debug"
path_file_tag_global_mirror="$path_dir_storage/mirror"
path_file_tag_skip="$path_dir_apps_storage/$PROC/skip"
path_file_tag_force="$path_dir_apps_storage/$PROC/force"
path_file_tag_mirror="$path_dir_apps_storage/$PROC/mirror"
path_file_tag_remove="$path_dir_apps_storage/$PROC/remove"
path_file_tag_install="$path_dir_apps_storage/$PROC/install"
# apps tag
path_file_tag_mounted="$path_dir_apps_module/$PROC/mounted"

# logger library required variables
# -----------------------
# [[ -v STAGE ]]  || export STAGE=boot-service
# [[ -v PROC ]]   || export PROC=magisk
# [[ -v UID ]]    || { UID=$(id -g) && export UID; }
# [[ -v PID ]]    || export PID=$$

# logger dummy fn
logme(){ :; }
# source lib
[ -d "$MODDIR/lib" ] && {
    # logger
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}
# logger configs
logger_process=$(printf "%-6s %-6s" "$UID" "$PID")
logger_special=$(printf "%-18s - %s" "$(basename "$0"):$STAGE" "$PROC")
# logger
logger_check(){
    if [[ -v LOGGER_MODULE ]] && [ -f "$path_file_tag_global_debug" ]; then
        [ -f "$path_file_logs" ] && {
            cat "$path_file_logs" >> "$path_dir_storage/module.log"
            printf "" > "$path_file_logs"
        }
    fi
}
# sanity checks
[ ! -d "$MIRROR/data" ] && {
    logme error "we failed to detect magisk mirror mount. skipping this process.."
    logger_check
    return 1
}
[[ ! -v PROC ]] && {
    logme error "we are expecting PROC but it is not defined. skipping this process.."
    logger_check
    return 1
}
# cleanup
[ -f "$path_file_tag_mounted" ] && {
    logme stats "detected restart tag file. skipping this process.."
    rm -rf "$path_file_tag_mounted"
    logger_check
    return 0
}
# prevent multiple process
[ -f "$path_file_tag_process" ] && {
    # check if process is still running
    _PID="$(cat "$path_file_tag_process")"
    pidof "$_PID" && {
        logme stats "$_PID is still running. skipping this process.."
        logger_check
        return 0
    }
    # remove path process
    rm -rf "$path_file_tag_process"
}
# send notifications
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynMountX' 'Tag' '$(printf "$1")'"
}
# get apk version
get_apk_version() {
    # 1 - variable to return
    # 2 - apk_path
    logme debug "get_apk_version() -> $2" 
    [ -z "$2" ] && return 1
    if [ -n "${2##*\/*}" ]; then
        logme debug "get_apk_version() -> using dumpsys"
        eval "$1=$(dumpsys package "$2" | grep versionName | cut -d= -f 2 | sed -n '1p')"
    elif [ -f "$2" ]; then
        logme debug "get_apk_version() -> using aapt"
        eval "$1=$(aapt2 dump badging "$2" | grep versionName | sed -e "s/.*versionName='//" -e "s/' .*//")"
    fi
}
# set permission
set_permissions() {
    chown "$2:$3" "$1"    || return 1
    chmod "$4" "$1"       || return 1
    local CON=$5
    [ -z "$CON" ] && CON=u:object_r:system_file:s0
    chcon "$CON" "$1"     || return 1
}
# set permission recursively
set_permissions_recursive() {
  find "$1" -type d 2>/dev/null | while read dir; do
    set_permissions "$dir" "$2" "$3" "$4" "$6"
  done
  find "$1" -type f -o -type l 2>/dev/null | while read file; do
    set_permissions "$file" "$2" "$3" "$5" "$6"
  done
}
# restart the app and prevent re-run of the script
start_me() {
    if [ ! -f "$path_file_tag_mounted" ];then
        logme debug "start_me() - restarting $PROC"
        am start -n "$(cmd package resolve-activity --brief "$PROC" | tail -n 1)"
        touch "$path_file_tag_mounted"
        # terminate the script
        return 0
    fi
}
# mount bind app
bind_me() {
    logme debug "bind_me() - $path_file_apk_module_base"
    logme debug "bind_me() - stopping app.."
    am force-stop "$PROC"
    # logme debug "bind_me() - disabling app.."
    # pm disable "$PROC"

    logme debug "bind_me() - unmounting remants.."
    mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
        logme debug "bind_me() - unmounting: $base_apk"
        umount -l "$base_apk"
    done

    logme debug "bind_me() - mounting.."
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"
    log_mount=$(mount -o bind "$path_file_apk_module_base" "$installed_path")
    [ ! $? = 0 ] && {
        logme error "bind_me() failed to mount -> $log_mount"
        logger_check
        return 1
    }

    logme debug "bind_me() - verifying mount.."
    if mount | grep -q "$installed_path";then
        logme stats "bind_me() - Mounted!"
        send_notification "Successfully Mounted!\n$PROC"
    else
        logme error "bind_me() - Failed to Mount.."
    fi

    [ -d "/data/data/$PROC/cache/" ] && {
        logme debug "bind_me() - clearing cache"
        rm -rf "/data/data/$PROC/cache/"
    }

    logme debug "bind_me() - Enabling App.."
    pm enable "$PROC"

    [ "$noRestart" = false ] && start_me
}
# install apk and mount bind app
install_me() {
    # install apk
    logme debug "install_me() - $path_file_apk_module_base"
    logme debug "install_me() - stopping app.."
    am force-stop "$PROC"
    # logme debug "install_me() - disabling app.."
    # pm disable "$PROC"

    logme debug "install_me() - unmounting remants.."
    mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
        logme debug "install_me() - unmounting: $base_apk"
        umount -l "$base_apk"
    done

    logme debug "install_me() - installing original apk.."
    log_install=$(pm install -d "$path_file_apk_module_orig")
    [ ! $? = 0 ] && {
        logme error "install_me() failed to install -> $log_install"
        logger_check
        return 1
    }

    logme debug "install_me() - mounting base apk"
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"
    log_mount=$(mount -o bind "$path_file_apk_module_base" "$installed_path")
    [ ! $? = 0 ] && {
        logme error "install_me() failed to mount -> $log_mount"
        logger_check
        return 1
    }

    
    version_apk_module_base=""
    version_apk_module_orig=""
    get_apk_version version_apk_module_base "$path_file_apk_module_base"
    get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
    printf %s "$version_apk_module_base" > "$path_file_tag_version_base"
    printf %s "$version_apk_module_orig" > "$path_file_tag_version_orig"

    logme debug "install_me() - verifying mount"
    if mount | grep -q "$installed_path";then
        logme stats "install_me() - Mounted!"
        send_notification "Successfully Mounted!\n$PROC"
    else
        logme error "install_me() - Failed to Mount."
    fi

    [ -d "/data/data/$PROC/cache/" ] && {
        logme debug "install_me() - clearing cache.."
        rm -rf "/data/data/$PROC/cache/"
    }

    logme debug "install_me() - Enabling App.."
    pm enable "$PROC"

    [ "$noRestart" = false ] && start_me
}
# normal main
main_normal() {
    # check if base and original apk are present
    [ ! -f "$path_file_apk_module_base" ] && {
        logme error "main_normal() - missing base.apk"
        return 1
    }

    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"

    version_apk_module_base=""
    version_apk_module_orig=""
    version_installed=""

    logme debug "main_normal() - getting versions.."

    if [ -f "$path_file_tag_version_base" ] && \
         grep '[^[:space:]]' "$path_file_tag_version_base"; then
        logme debug "main_normal() - using version_base file.."
        version_apk_module_base=$(cat "$path_file_tag_version_base")
    else
        logme debug "main_normal() - creating version_base file.."
        get_apk_version version_apk_module_base "$path_file_apk_module_base"
        printf %s "$version_apk_module_base" >  "$path_file_tag_version_base"
    fi
    if { [ -f "$path_file_tag_version_orig" ] && \
        grep '[^[:space:]]' "$path_file_tag_version_orig"; }; then
        logme debug "main_normal() - using version_orig file.."
        version_apk_module_orig=$(cat "$path_file_tag_version_orig")
    else
        logme debug "main_normal() - creating version_orig file.."
        get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
        printf %s "$version_apk_module_orig" >  "$path_file_tag_version_orig"
    fi
    
    get_apk_version version_installed "$PROC"
    
    logme debug "main_normal() - detected versions:"
    logme debug "main_normal() - installed   - $version_installed"
    logme debug "main_normal() - module_base - $version_apk_module_base"
    logme debug "main_normal() - module_orig - $version_apk_module_orig"

    # check version installed vs module
    if [ "$version_installed" != "$version_apk_module_base" ];then
        logme error "main_normal() - version mismatch: installed=$version_installed, module=$version_apk_module_base"
        # check if base.apk matches original.apk
        [ "$version_apk_module_base" != "$version_apk_module_orig" ] && {
            logme error "main_normal() - version mismatch: base=$version_apk_module_base, original=$version_apk_module_orig"
            # exit
            return 1
        }
        logme stats "main_normal() - reinstalling..., calling install_me()"
        install_me
    elif [ "$version_installed" = "$version_apk_module_base" ];then
        # versions are aligned check if mounted
        if mount | grep -q "$installed_path";then
            logme stats "main_normal() - already mounted."
        else
            logme stats "main_normal() - not mounted..., calling bind_me()"
            bind_me
        fi
    fi
}
# main process
main() {
    logme debug "main() - processing"

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
        logme debug "main() - processing tags."
        [ ! -d "$path_dir_apps_module/$PROC" ]  && mkdir -p "$path_dir_apps_module/$PROC"
        [ ! -d "$path_dir_apps_storage/$PROC" ] && mkdir -p "$path_dir_apps_storage/$PROC"
        ## tag file mode
        [ -f "$path_file_tag_install" ] && {
            # install
            # install the package_dir
            logme debug "main() - tag:install"
            rm -rf "$path_file_tag_install"
            if [ -f "$path_file_apk_storage_base" ] && [ -f "$path_file_apk_storage_orig" ]; then
                # cp to module
                logme debug "main() - tag:install - copying storage to module dir"
                cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base"
                cp -rf "$path_file_apk_storage_orig" "$path_file_apk_module_orig"
                set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                install_me || return 1
                return 0
            elif [ -f "$path_file_apk_storage_base" ] && [ ! -f "$path_file_apk_storage_orig" ];then
                logme debug "main() - tag:install - trying bind mode only."
                version_apk_storage_base=""
                version_installed=""
                get_apk_version version_apk_storage_base "$path_file_apk_storage_base"
                get_apk_version version_installed       "$PROC"
                if [ "$version_apk_storage_base" = "$version_installed" ];then
                    logme debug "main() - tag:install - copying storage base to module dir"
                    cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base"
                    set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                    bind_me || return 1
                    return 0
                fi
                logme debug "main() - tag:install - version mismatch, installed=$version_installed base=$version_apk_storage_base"
                logme error "main() - tag:install - cannot proceed with bind mode due to installed apk does not match with base apk"
                return 1
            else              
                logme error "main() - tag:install - failed, missing storage base or original apk."
                touch "$path_dir_apps_storage/$PROC/install_failed"
            fi
        }
        [ -f "$path_file_tag_force" ] && {
            # force
            # force mount
            logme debug "main() - tag:force_mount"
            rm -rf "$path_file_tag_force"
            if [ -f "$path_file_apk_module_base" ] && [ -f "$path_file_apk_module_base" ]; then
                bind_me || return 1
                return 0
            else
                logme debug "main() - tag:force_mount - failed, missing module base or original apk."
                touch "$path_dir_apps_storage/$PROC/force_mount_failed"
            fi
        }
        [ -f "$path_file_tag_skip" ] && {
            # skip
            # skip mount
            logme debug "main() - tag:skip"
            logme debug "main() - tag:skip - skipping app.."
            return 0
        }
        [ -f "$path_file_tag_remove" ] && {
            # remove
            # remove the module package dir
            logme debug "main() - tag:remove"
            rm -rf "$path_file_tag_remove"
            # unmount remnants
             mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
                logme debug "main() - tag:remove - unmounting: $base_apk"
                umount -l "$base_apk"
            done
            # remove package
            rm -rf "${path_dir_apps_module:?}/$PROC" && touch "$path_dir_apps_storage/$PROC/remove_success"
            return 0
        }
        [ -f "$path_file_tag_mirror" ] && [ ! -f "$path_file_tag_global_mirror" ] && {
            # mirror app level
            # mirror the package_name dir to internal directory
            logme debug "main() - tag:mirror_app_level"
            rm -rf "$path_file_tag_mirror"
            cp -rf "${path_dir_apps_module:?}/$PROC" "$path_dir_apps_storage"
        }
        [ -f "$path_file_tag_global_mirror" ] && {
            # mirror global
            # mirror the apps dir to root internal directory
            logme debug "main() - tag:mirror_global"
            rm -rf "$path_file_tag_global_mirror"
            cp -rf "$path_dir_apps_module" "$path_dir_storage"
        }
    }
    # proceed with normal checks
    main_normal
}
main
# clean up calls
# store the current PID
printf "$PID" > "$path_file_tag_process"
# special tag debug
logger_check