#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# magisk_module required
export MODDIR="${0%/*}"
export MODNAME="${MODDIR##*/}"

# config-paths
# ------------

# magisk Busybox & module local binaries
PATH="$MODDIR/bin:$PATH:$MAGISKTMP/.magisk/busybox:$PATH"


# API_VERSION = 1
export STAGE="$1"  # prepareEnterMntNs or EnterMntNs
export PID="$2"    # PID of app process
export UID="$3"    # UID of app process
export PROC="$4"   # Process name. Example: com.google.android.gms.unstable
export USERID="$5" # USER ID of app
# API_VERSION = 2
# Enable ash standalone
# Enviroment variables: MAGISKTMP, API_VERSION
# API_VERSION = 3
# STAGE="$1"  # prepareEnterMntNs or EnterMntNs or OnSetUID


# config-static_variables 
# -----------------------
# apps folder
path_dir_storage="/sdcard/DynamicMountManagerX"
path_dir_apps_module="$MODDIR/apps"
path_dir_apps_storage="$path_dir_storage/apps"


# log file
export path_file_log="$MODDIR/module.log"

# dummy fn
logme(){ :; }
# source lib
[ -d "$MODDIR/lib" ] && {
    # logger
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}

exit_script() {
    # clean up before exit
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

	# minimum process monitor tool v3
    [ "$API_VERSION" -lt 2 ] && {
        exit_script 1
    }

	# app specific
    if [ -d "$path_dir_apps_module/$PROC" ] || [ -d "$path_dir_apps_storage/$PROC" ]; then
        su 0 -mm -c sh "$MODDIR/manager.sh"
        exit_script 1
    fi

    # # task specific
    # [ "$UID" -lt 10000 ] && {
    #     # validate call, only execute once every 6 mins or more.
    #     # last_task
    #     last_task="$MODDIR/last_task"
    #     [ -f "$last_task" ] && \
    #     [ "$(echo "time_diff=$(date %s) - $(cat "$last_task");time_diff<6" | bc -l)" = 1 ] && {
    #         exit_script 1
    #     }
    #     # call task
    #     :;
    #     # update last_task
    #     date +%s > "$last_task"
    # }
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