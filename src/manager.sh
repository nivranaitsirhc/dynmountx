#!/system/bin/sh
# shellcheck shell=ash
# shellcheck source=/dev/null

# check module variables

# check MODDIR definition
[ -z ${MODDIR+x} ] && {
    MODDIR="${0%/*}"
}

# check MODNAME definition
[ -z ${MODNAME+x} ] && {
    MODNAME="${MODDIR##*/}"
}

# check magisk temporary directory
[ -z ${MAGISKTMP+x} ] && {
    MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin
}

# add magisk busybox & module binaries
PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"

# no auto restart
noRestart=false
# no send notifications
noNotifications=false
# parse script parameters
[ "$1" = "disableRestart" ]        && noRestart=true
[ "$2" = "disableNotificaitons" ]  && noNotifications=true


# sdcard directory
path_dir_storage="/sdcard/DynamicMountManagerX"
# app directory - adb
path_dir_apps_module="/data/adb/apps"
# app directory - storage
path_dir_apps_storage="$path_dir_storage/apps"

# app tag files
path_file_tag_version_base="$path_dir_apps_module/$PROC/version_base"
path_file_tag_version_orig="$path_dir_apps_module/$PROC/version_orig"

# app running tag
path_file_tag_process="$path_dir_apps_module/$PROC/running"
remove_running=true

# apk files location
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
path_file_tag_enable="$path_dir_apps_storage/$PROC/enable"
path_file_tag_disable="$path_dir_apps_storage/$PROC/disable"
path_file_tag_install="$path_dir_apps_storage/$PROC/install"
path_file_tag_install_all="$path_dir_apps_storage/$PROC/all"
# apps tag
path_file_tag_mounted="$path_dir_apps_module/$PROC/mounted"


# check global debug variable if not set then set
[ -z ${config_debug+x} ] && {
    # check global tag file
    if [ -f "$path_file_tag_global_debug" ]; then
        # enable debug variable
        config_debug=true
    else
        # disable debug variable
        config_debug=false
    fi
    # export debug flag
    export config_debug
}


# check log_instance if already defined by dynmount.sh or service.sh
[ -z ${path_file_logs+x} ] && {
    # set standalone to true, handle logging cleanup
    standaloneMode=true

    # instance log name
    log_instance_name="dynmount-$(date +%y-%m-%d_%H-%M-%S).log"
    # temp location to store log will be cache
    path_file_logs="/cache/$log_instance_name"

    # redirect final log to sdcard log file else to cache log file
    if [ -d "$path_dir_storage" ];then
        path_file_logs_final="$path_dir_storage/module.log"
    else
        path_file_logs_final="/cache/dynmount-module.log"
    fi
}

# logger library required variables
# -----------------------
[ -z "${STAGE+x}" ]  && STAGE=standalone
# [ -z "${PROC+x}" ]   && PROC=magisk
[ -z "${UID+x}" ]    && UID=$(id -g)
[ -z "${PID+x}" ]    && PID=$$

# dummy logger function
logme(){ :; }
# source libraries
[ -d "$MODDIR/lib" ] && {
    # logger library
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}
# customize logger data
# shellcheck disable=SC2034
logger_process=$(printf "%6s %6s" "$UID" "$PID")
# shellcheck disable=SC2034
logger_special=$(printf "%-30s - %s" "$(basename "$0"):$STAGE" "$PROC")

# copy final log from instance to final log final
logger_check() {
    # check if path_file_logs is still present
    [ -f "$path_file_logs" ] && [ -d "$path_dir_storage" ] && {
        # copy instance log to final log destination
        cat "$path_file_logs" >> "$path_file_logs_final"
        # remove instance log
        rm -f "$path_file_logs"
    }
}

# clean-exit
clean_exit() {
    local exitCode="${1:-0}"
    
    # default remove running tag
    [ "$remove_running" = true ] && {
        rm -f "$path_file_tag_process"
    }

    # logger clean-up
    [ "$standaloneMode" = true ] &&\
    logger_check
    
    exit "$exitCode"
}

# send notifications
notif_int="$(getprop ro.build.version.release)"
send_notification() {
    # disable notifications on android running older than android 10
    [ "$notif_int" -ge 10 ] && {
        # disable notifications
        if [ "$noNotifications" != true ];then
            # shellcheck disable=SC2059
            su 2000 -c "cmd notification post -S bigtext -t 'DynMountX' 'Tag' '$(printf "$1")'"
        fi
    }
}

# exit if PROC is not defined
[ -z "${PROC+x}" ] && {
    logme error "skipping process.. \$PROC is not defined."
    clean_exit 1
}

# skip if skip_tag present
[ -f "$path_file_tag_mounted" ] && {
    logme stats "skipping process.. detected \"skip\" tag for $PROC."
    rm -f "$path_file_tag_mounted"
    clean_exit 1
}

# prevent parallel execution for PROC
if [ -f "$path_file_tag_process" ];then
    logme debug "tag:running - detected running tag."
    # get last count
    runningCount=$(cat "$path_file_tag_process")
    # check runningCount if is a valid number

    if printf %d "runningCount" > /dev/null 2>&1; then
        # check if running is within threshold of 2
        if [ "$runningCount" -gt "1" ]; then
            logme debug "tag:running - reached the max allowed skip. proceeding.."
        else
            # update count
            currentCount=$(("$runningCount" + 1))
            echo "$currentCount" > "$path_file_tag_process"
            logme debug "tag:running - current count is $currentCount"

            logme infor "tag:running - another instance is currently mounting this $PROC. skipping..."

            # stop the app
            logme infor "tag:running - stoping $PROC.."
            am force-stop "$PROC"

            # do not remove tag
            remove_running=false

            # exit
            clean_exit 0
        fi
    else
        logme debug "tag:running - running count is not a number: $runningCount, proceeding.."
        # reset running tag
        echo 0 > "$path_file_tag_process"
    fi
else
    # create running tag
    echo 0 > "$path_file_tag_process"
fi


# get apk version by path or by package name
get_apk_version() {
    # 1 - variable to return
    # 2 - apk_path
    logme debug "get_apk_version() -> $2" 
    [ -z "$2" ] && {
        logme error "get_apk_version() - empty path or package name returning null."
        eval "$1=\"\""
        return 1
    }
    if [ -f "$2" ]; then
        logme debug "get_apk_version() -> using aapt"
        eval "$1=$(aapt2 dump badging "$2" | grep versionName | sed -e "s/.*versionName='//" -e "s/' .*//")"
    elif [ -n "${2##*\/*}" ]; then
        logme debug "get_apk_version() -> using dumpsys"
        eval "$1=$(dumpsys package "$2" | grep versionName | cut -d= -f 2 | sed -n '1p')"
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
  find "$1" -type d 2>/dev/null | while read -r dir; do
    set_permissions "$dir" "$2" "$3" "$4" "$6"
  done
  find "$1" -type f -o -type l 2>/dev/null | while read -r file; do
    set_permissions "$file" "$2" "$3" "$5" "$6"
  done
}

# restart the app and prevent re-run of the script
start_me() {
    # create tag file mounted in the module app directory
    touch "$path_file_tag_mounted"

    # skip app restart if noRestart is true
    [ "$noRestart" = true ] && {
        logme debug "start_me() - skipping restart.. noRestart flag set to true."
        rm -f "$path_file_tag_mounted"
        return 0
    }

    logme debug "start_me() - restarting $PROC"
    am start -n "$(cmd package resolve-activity --brief "$PROC" | tail -n 1)"
    # terminate the script
    clean_exit 0
}

# special function handling the binding and installation of apk
install_bind() {
    # default operation will be to install and bind
    local install=true

    # disable install if $1 is set to false or bind
    if [ "$1" = false ] || [ "$1" = "bind" ];then
        install=false
        logme debug "install_bind() - running in bind mode"
    else
        logme debug "install_bind() - running in install mode"
    fi
    
    # 
    logme debug "install_bind() - $path_file_apk_module_base"
    
    # stop the application
    logme debug "install_bind() - stopping app.."
    am force-stop "$PROC"

    # disable the application
    # logme debug "install_bind() - disabling app.."
    # pm disable "$PROC"

    # check for previous mount that will match the package name and unmount them.
    logme debug "install_bind() - checking remants.."
    mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
        logme debug "install_bind() - unmounting: $base_apk"
        umount -l "$base_apk"
    done

    # use install feature
    [ "$install" = true ] && {
        # default to user 0 on reinstall
        user_install="--user 0"

        # disable user install when tag "install_all" is set
        [ -f "$path_file_tag_install_all" ] && {
            user_install=""
        }

        # install original apk
        logme debug "install_bind() - installing original apk.."
        local log_install=""
        local log_install_1=""
        local log_uninstall_0=""

        # shellcheck disable=SC2086
        log_install=$(pm install -r -d $user_install "$path_file_apk_module_orig" 2>&1)
        # shellcheck disable=SC2181
        [ "$?" -ne "0" ] && {
            # check if due to version downgrade then uninstall and install
            if echo "$log_install" | grep "INSTALL_FAILED_VERSION_DOWNGRADE"; then
                logme stats "install_bind() - version downgrade error. removing upgraded applacation with intact user data (if supported)"
                log_uninstall_0=$(pm uninstall -k "$PROC" )
                [ "$?" -ne "0" ] && {
                    logme debug "install_bind() - un-install failed with error: $log_uninstall_0"
                    clean_exit 1
                }
                
                # shellcheck disable=SC2086
                # try to re-install
                log_install_1=$(pm install -r -d $user_install "$path_file_apk_module_orig" 2>&1)
                [ "$?" -ne "0" ] && {
                    logme error "install_bind() - 2nd try failed to install with error: $log_install_1"
                    clean_exit 1
                }
            else
                logme error "install_bind() - failed to install with error: $log_install"
                clean_exit 1
            fi
        }

        # refresh verion tag files
        local version_apk_module_base=""
        local version_apk_module_orig=""
        get_apk_version version_apk_module_base "$path_file_apk_module_base"
        get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
        printf %s "$version_apk_module_base" > "$path_file_tag_version_base"
        printf %s "$version_apk_module_orig" > "$path_file_tag_version_orig"

    }

    # re-bind base apk
    logme debug "install_bind() - mounting base apk"
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"
    log_mount=$(mount -o bind "$path_file_apk_module_base" "$installed_path" 2>&1)
    [ ! $? = 0 ] && {
        logme error "install_bind() - failed to mount with error: $log_mount"
        clean_exit 1
    }

    # verify new bind
    logme debug "install_bind() - verifying mountpoint"
    if mount | grep -q "$installed_path";then
        logme stats "install_bind() - mounted!"
        send_notification "Successfully Mounted!\n$PROC"
    else
        logme error "install_bind() - failed to mount not found."
        clear_exit 1
    fi

    # clear application cache
    [ -d "/data/data/$PROC/cache/" ] && {
        logme debug "install_bind() - clearing cache"
        rm -rf "/data/data/$PROC/cache/"
    }

    # re-enable the application
    # logme debug "install_bind() - enabling App.."
    # pm enable "$PROC"

    # call start me
    start_me
}

# main
main() {
    local installed_path
    local version_apk_module_base
    local version_apk_module_orig
    local version_installed

    # check base.apk if present
    [ ! -f "$path_file_apk_module_base" ] && {
        logme error "main() - critical error: missing base.apk"
        clean_exit 1
    }

    # update base apk installed path
    installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"

    logme debug "main() - getting versions.."

    # future implementation should be:
    # - limited use of version base file
    # - should put an age in using version base file
    # - renew version base file when age is old

    # query apk version - base.apk
    if [ -f "$path_file_tag_version_base" ] && \
         grep '[^[:space:]]' "$path_file_tag_version_base"; then
        logme debug "main() - using version_base file.."
        version_apk_module_base=$(cat "$path_file_tag_version_base")
    else
        logme debug "main() - creating version_base file.."
        get_apk_version version_apk_module_base "$path_file_apk_module_base"
        printf %s "$version_apk_module_base" >  "$path_file_tag_version_base"
    fi

    # query apk version - original.apk
    if { [ -f "$path_file_tag_version_orig" ] && \
        grep '[^[:space:]]' "$path_file_tag_version_orig"; }; then
        logme debug "main() - using version_orig file.."
        version_apk_module_orig=$(cat "$path_file_tag_version_orig")
    else
        logme debug "main() - creating version_orig file.."
        get_apk_version version_apk_module_orig "$path_file_apk_module_orig"
        printf %s "$version_apk_module_orig" >  "$path_file_tag_version_orig"
    fi
    
    # query apk version - installed application
    get_apk_version version_installed "$PROC"
    
    # display versions
    logme infor "main() - listing versions:"
    logme infor "main() - current installed -> :$version_installed"
    logme infor "main() - module patched    -> :$version_apk_module_base"
    logme infor "main() - module original   -> :$version_apk_module_orig"

    # base.apk does not match with installed
    if [ "$version_installed" != "$version_apk_module_base" ];then
        logme error "main() - version mismatch: installed=$version_installed, module=$version_apk_module_base"
        logme infor "main() - current installed does not match with stored base.apk, try to downgrade or re-install the stored original apk."
        
        # base.apk does not match with original.apk - error quit.
        if [ "$version_apk_module_base" != "$version_apk_module_orig" ]; then
            logme error "main() - version mismatch: base=$version_apk_module_base, original=$version_apk_module_orig"
            logme infor "main() - the module base.apk and original.apk does not match. exiting.."
            # exit the script
            clean_exit 1

        # base.apk matches with orig.apk
        else
            logme stats "main() - reinstalling..., calling install_me() in install mode."
            # call install_bind in install mode.
            install_bind
        fi
    # base.apk matches with installed
    else
        # base.apk is mounted.
        if mount | grep -q "$installed_path";then
            logme stats "main() - already mounted."
        # base.apk is not mounted
        else
            logme stats "main() - not mounted..., calling install_bind() in bind mode"
            # call install_bind in bind mode.
            install_bind bind
        fi
    fi
}

# main process
init_main() {
    logme debug "init_main() - initializing.."

    # tag files check
    # 1.  "enable" tag file must be present in internal storage directory.
    # 1.a "mirror" tag file will mirror the installed pacakges in module to internal storage.
    # 2. "package_name" dir must exist in internal storage directory.

    # Recognized tag files    Description
    # ------------------------------------------------------------------------------------------
    # install               - install the app from the internal sdcard apps directory.
    # remove                - un-mount and removes the module copy
    # force                 - re-mount the pacakge in module dir.
    # mirror                - copy the module apps directory to internal storage app directory.
    # skip                  - skip-mount of the application name.


    # check the tag file "enable" in internal storage
    if [ -d "$path_dir_storage" ] && [ -f "$path_dir_storage/enable" ];then
        logme stats "init_main() - internal storage \"enable\" tag found, checking for tags.."

        # create path for the current package name in module & internal storage
        [ ! -d "$path_dir_apps_module/$PROC" ]  &&\
        mkdir -p "$path_dir_apps_module/$PROC"
        [ ! -d "$path_dir_apps_storage/$PROC" ] &&\
        mkdir -p "$path_dir_apps_storage/$PROC"
        

        # (blocking) process application tag - "disable"
        [ -f "$path_file_tag_disable" ] && {
            logme stats "init_main() - tag:disable"
            # remove the disable tag file from internal app director.
            rm -f "$path_file_tag_disable"

            # un-mount application
            logme debug "init_main() - tag:disable - checking remnants"
            mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
                logme debug "init_main() - tag:disable - unmounting: $base_apk"
                umount -l "$base_apk"
            done

            logme debug "init_main() - tag:disable - creating disable tag file and exiting.."
            # add disable tag to application module directory
            touch "$path_dir_apps_module/$PROC/disable"

            logme stats "init_main() - tag:disable - disabled $PROC"

            # exit the script
            clean_exit 0
        }

        # (blocking) process application tag - "install"
        [ -f "$path_file_tag_install" ] && {
            logme stats "init_main() - tag:install"
            
            # remove the install tag file from internal app directory.
            rm -f "$path_file_tag_install"
            
            # complete install - base.apk, orig.apk are present.
            if [ -f "$path_file_apk_storage_base" ] && [ -f "$path_file_apk_storage_orig" ]; then
                logme debug "init_main() - tag:install - copying storage to module dir"

                # copy base.apk and orig.apk to application module directory
                cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base"
                cp -rf "$path_file_apk_storage_orig" "$path_file_apk_module_orig"

                # set permissions
                set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                
                # call install_bind in install mode.
                install_bind

            # bind only install mode - base.apk only
            elif [ -f "$path_file_apk_storage_base" ] && [ ! -f "$path_file_apk_storage_orig" ];then
                logme debug "init_main() - tag:install - trying bind mode."

                # define local variables
                local version_apk_storage_base=""
                local version_installed=""
                get_apk_version version_apk_storage_base    "$path_file_apk_storage_base"
                get_apk_version version_installed           "$PROC"

                # compare version base.apk with installed version 
                if [ "$version_apk_storage_base" = "$version_installed" ];then
                    logme debug "init_main() - tag:install - copying internal storage base.apk to application module directory.."

                    # copy base.apk to applicaiton module directory
                    if cp -rf "$path_file_apk_storage_base" "$path_file_apk_module_base";then
                        logme debug "init_main() - tag:install - backing-up installed original base.apk"

                        # get isntalled path
                        local installed_path=""
                        installed_path="$(pm path "$PROC" | head -1 | sed 's/^package://g' )"

                        # copy base.apk
                        if cp -rf "$installed_path" "$path_file_apk_module_orig";then
                            # set permissions for apk files.
                            set_permissions_recursive "$path_dir_apps_module/$PROC" "root" "root" 0755 0644 u:object_r:magisk_file:s0
                            # call install_bind in bind mode.
                            install_bind bind
                        else
                            logme error "init_main() - tag:install - failed to copy original base apk from installed path"
                        fi
                    else
                        logme error "init_main() - tag:install - failed to copy base.apk to module app dir"
                    fi
                else
                    logme debug "init_main() - tag:install - version mismatch, installed=$version_installed base=$version_apk_storage_base"
                    logme error "init_main() - tag:install - cannot proceed with bind mode due to installed apk does not match with base apk"
                fi
            else
                logme error "init_main() - tag:install - failed, missing storage base.apk."
                echo "install tag: failed missing base.apk or original.apk" > "$path_dir_apps_storage/$PROC/install_failed.txt"
            fi
            
            
            # exit the script
            clean_exit 0
        }

        # (blocking) process application tag - "force"
        [ -f "$path_file_tag_force" ] && {
            logme stats "init_main() - tag:force_mount"
            
            # remove the force tag file from internal app directory.
            rm -f "$path_file_tag_force"

            # complete install - base.apk, orig.apk are present.
            if [ -f "$path_file_apk_module_base" ] && [ -f "$path_file_apk_module_base" ]; then
                logme stats "init_main() - tag:force_mount - calling install_bind in install mode"
                install_bind
            # bind mode only.
            elif [ -f "$path_file_apk_module_base" ];then
                logme stats "init_main() - tag:force_mount - calling install_bind in bind mode"
                install_bind bind
            else
                # error
                logme stats "init_main() - tag:force_mount - failed, missing module base.apk or original.apk"
                echo "force tag: failed force install - missing base.apk and/or original.apk" > "$path_dir_apps_storage/$PROC/force_mount_failed.txt"
            fi
            
            # exit the script
            clean_exit 0
        }

        # (blocking) process application tag - "remove"
        [ -f "$path_file_tag_remove" ] && {
            logme stats "init_main() - tag:remove"

            # remove the remove tag file from internal app directory.
            rm -f "$path_file_tag_remove"

            # unmount remnants
            logme debug "init_main() - tag:remove - checking remnants.."
             mount | grep "$PROC" | cut -d ' ' -f 3 | while IFS= read -r base_apk || [ -n "$base_apk" ]; do
                logme debug "init_main() - tag:remove - unmounting: $base_apk"
                umount -l "$base_apk"
            done
            
            # remove application module directory
            if rm -rf "${path_dir_apps_module:?}/$PROC";then
                touch "$path_dir_apps_storage/$PROC/remove_success"
                logme stats "init_main() - tag:remove - successfully removed module application directory"
            else
                logme error "init_main() - tag:remove - failed to remove module application directory"
            fi

            # exit the script
            clean_exit 0
        }

        
        # (blocking) process application tag - "skip"
        [ -f "$path_file_tag_skip" ] && {
            logme stats "init_main() - tag:skip - skipping application.."

            # exit the script
            clean_exit 0
        }

        
        # (non-blocking) process application tag - "enable"
        [ -f "$path_file_tag_enable" ] && {
            logme stats "init_main() - tag:enable"
            # remove the enable tag file from internal app directory.
            rm -f "$path_file_tag_enable"

            logme debug "init_main() - tag:enable - removing module disable tag"
            # remove the disable tag in module app directory
            rm -f "$path_dir_apps_module/$PROC/disable"

            logme stats "init_main() - tag:enable - enabled $PROC"
        }


        # (non-blocking) process application tag - "mirror"
        [ -f "$path_file_tag_mirror" ] && [ ! -f "$path_file_tag_global_mirror" ] && {
            # mirror the package_name dir to internal directory
            logme stats "init_main() - tag:mirror_app_level"

            # remove the mirror tag file from internal app directory.
            rm -f "$path_file_tag_mirror"
            
            # copy the application module directory to internal storage application directory
            if ! cp -rf "${path_dir_apps_module:?}/$PROC" "$path_dir_apps_storage";then
                logme error "init_main() - tag:mirror_app_level - failed to copy application directory"
            else
                logme stats "init_main() - tag:mirror_app_level -  successfuly copied whole application module directory to internal storage"
            fi
        }

    fi

    # (non-blocking) process global tag - "mirror"
    [ -f "$path_file_tag_global_mirror" ] && {
        # mirror the apps dir to root internal directory
        logme stats "init_main() - tag:mirror_global"

        # remove the global mirror tag in module application directory.
        rm -f "$path_file_tag_global_mirror"

        if ! cp -rf "$path_dir_apps_module" "$path_dir_storage";then
            logme error "init_main() - tag:mirror_global - failed to copy the whole module application directory to internal storage"
        else
            logme stats "init_main() - tag:mirror_global - successfuly copied whole application module directory to internal storage"
        fi
    }

    # proceed with normal checks
    main
}

# run init
init_main

# remove process tag
clean_exit 0