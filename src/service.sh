#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# Wait until boot is completed
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1;done

# Wait until /sdcard is mounted is available
until [ -d "/sdcard/DynamicMountManagerX" ]; do sleep 1;done

# magisk module variables
MODDIR="${0%/*}"
MODNAME="${MODDIR##*/}"
MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin

export MODDIR
export MODNAME
export MAGISKTMP

# disable manager.sh execution from dynmount.sh
echo 0 > "$MODDIR/bootscript"

# manager.sh required variables
# -----------------------
[[ -v STAGE ]]  || STAGE=boot-service
# [[ -v PROC ]]   || PROC=magisk
[[ -v UID ]]    || UID=$(id -g)
[[ -v PID ]]    || PID=$$

export STAGE
export UID
export PID


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
logger_process=$(printf "%-6s %-6s" "$UID" "$PID")
logger_special=$(printf "%-18s - %s" "$(basename "$0"):$STAGE" "$PROC")

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
send_notification() {
    su 2000 -c "cmd notification post -S bigtext -t 'DynMountX' 'Tag' '$(printf "$1")'"
}


# SC2031
if shopt -s lastpipe;then
    logme debug "shopt did not work."
fi

mountedAppList="$MODDIR/mountedAppList.txt"


# query applications folder list and validate
ls "/data/adb/apps" | while read -r PROC; do
    if [ ! -f "/data/adb/apps/$PROC/disable" ];then
        # export current PROC
        export PROC
        logme stats "loop(): calling manager.sh for $PROC"
        # call manager.sh
        su 0 -c "$MODDIR/manager.sh" disableRestart disableNotificaitons

        # verify mountpoint
        if mount | grep -q "$PROC";then
            printf "\n$PROC" >> "$mountedAppList"
        fi
    else
        logme stats "loop(): skipping $PROC, disable tag found"
    fi
done
logme stats "done boot-script"

# remove bootscript tag
rm -f "$MODDIR/bootscript"

# get mounted app list
mountedAppList=$(cat "$mountedAppList")
# remove list
rm -f "$MODDIR/mountedAppList.txt"

# send notificatons to user
if [ "$mountedAppList" != "" ];then
    send_notification "Successfully Mounted$mountedAppList"
fi

# exit
logger_check