#!/system/bin/sh
# shellcheck shell=ash
# shellcheck source=/dev/null

# magisk module directory
MODDIR="${0%/*}"
# magisk module name
MODNAME="${MODDIR##*/}"
MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin
export MODDIR
export MODNAME
export MAGISKTMP

# magisk busybox & module local binaries
PATH="$MODDIR/bin:$MAGISKTMP/.magisk/busybox:$PATH"


# API_VERSION = 1
STAGE="$1"  # prepareEnterMntNs or EnterMntNs
PID="$2"    # PID of app process
UID="$3"    # UID of app process
PROC="$4"   # Process name. Example: com.google.android.gms.unstable
USERID="$5" # USER ID of app
# API_VERSION = 2
# Enable ash standalone
# Enviroment variables: MAGISKTMP, API_VERSION
# API_VERSION = 3
# STAGE="$1"  # prepareEnterMntNs or EnterMntNs or OnSetUID
# API_VERSION = 4
# Enviroment variables provided by KernelSU: 
# KSU_VERSION - KernelSU version, "-1" is not installed
# KSU_ON_UNMOUNT - true if process is on unmount
# KSU_ON_GRANTED - true if process is granted su access
# For Magisk, please use magisk command, example: MAGISKTMP="$(magisk --path)"

export STAGE
export PID
export UID
export PROC
export USERID


# config-static_variables 
# -----------------------
# apps folder
path_dir_storage="/sdcard/DynamicMountManagerX"
path_dir_apps_module="$MODDIR/apps"
path_dir_apps_storage="$path_dir_storage/apps"


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
export path_file_logs
export path_file_logs_final


# dummy logger function
logme(){ :; }
# source libraries
[ -d "$MODDIR/lib" ] && {
    # logger library
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}
# customize logger data
logger_setup(){
    # shellcheck disable=SC2034
    logger_process=$(printf "%6s %6s" "$UID" "$PID")
    # shellcheck disable=SC2034
    logger_special=$(printf "%-30s - %s" "$(basename "$0"):$STAGE" "$PROC")
}
# init logger_setup for dynmount
logger_setup

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

# send notifications
notif_int="$(getprop ro.build.version.release)"
send_notification() {
    # disable notifications on android running older than android 10
    [ "$notif_int" -ge 10 ] && {
        # shellcheck disable=SC2154
        # disable notifications
        if [ "$noNotifications" != true ];then
            su 2000 -c "cmd notification post -S bigtext -t 'DynMountX' 'Tag' '$(printf "$1")'"
        fi
    }
}


# clean up before exit
exit_script() {
    # call logger_check
    logger_check
    # exit
    exit "$1"
}

RUN_SCRIPT(){
    if [ "$STAGE" = "prepareEnterMntNs" ]; then
        prepareEnterMntNs
    elif [ "$STAGE" = "EnterMntNs" ]; then
        EnterMntNs
    elif [ "$STAGE" = "OnSetUID" ]; then
        OnSetUID
    fi
}


prepareEnterMntNs(){
    # this function run on app pre-initialize

	# app specific
    if [ -d "$path_dir_apps_module/$PROC" ] || [ -d "$path_dir_apps_storage/$PROC" ]; then
        # local exitCode=0

        # detect boot-script tag
        # bootscript tag is generated by service.sh it must not be present after service.sh
        local bootscript="$MODDIR/bootscript"
        [ -f "$bootscript" ] && {
            bootscriptcount=$(cat "$bootscript")
            if [ "$bootscriptcount" -lt 3 ];then
                logme stats "bootscript detected with $bootscriptcount count, incrementing count and exiting.."
                bootscriptcount=$((bootscriptcount + 1))
                echo "$bootscriptcount" > "$bootscript"
                exit_script 1
            else
                logme infor "number of boot checks exceeded this might be caused by a dirty exit. proceeding.."
                rm -f "$bootscript"
            fi
        }
        
        # run manger.sh with exported variables
        logme infor "running manager.sh..."
        "$MODDIR"/manager.sh
        # [ $? -ne 0 ] && {
        #     # exited with error; update exit code to 1
        #     exitCode=1
        # } 

        # reset logger
        logger_setup
        
        # done
        logme infor "done dynamic-mount service!"
    fi
    
    exit_script 1 # close script
}
EnterMntNs(){
    # this function will be run when mount namespace of app process is unshared
    # call exit_script 0 to let script to be run in OnSetUID
    exit_script 1 # close script
}
OnSetUID(){
    # this function will be run when UID is changed from 0 to $UID
    exit_script 1 # close script
}

RUN_SCRIPT