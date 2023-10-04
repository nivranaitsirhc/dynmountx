#!/system/bin/ash
# shellcheck shell=ash
# shellcheck source=/dev/null

# Wait until boot is completed
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 1;done

# Wait until /sdcard is mounted and available
until [ -d "/sdcard/DynamicMountManagerX" ]; do sleep 1;done

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

export MODDIR
export MODNAME
export MAGISKTMP

# disable manager.sh execution from dynmount.sh
echo 0 > "$MODDIR/bootscript"

# manager.sh required variables
# -----------------------
[ -z ${STAGE+x} ]  && STAGE=boot-service
# [ -n ${PROC+x} ]   && PROC=magisk
[ -z ${UID+x} ]    && UID=$(id -g)
[ -z ${PID+x} ]    && PID=$$

export STAGE
export UID
export PID


path_dir_storage="/sdcard/DynamicMountManagerX"
# path_dir_apps_module="$MODDIR/apps"
# path_dir_apps_storage="$path_dir_storage/apps"


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
    logger_special=$(printf "%-30s - %s" "service.sh:boot-service" "init_process")
}
# init logger_setup
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

# mkdir
mountedAppList="$MODDIR/mountedAppList.txt"

# init mounted mountedAppList
[ -f "$mountedAppList" ] && {
    # remove remant list file 
    rm -f "$mountedAppList"
}
touch "$mountedAppList"

# shellcheck disable=SC2012
# query applications folder list and validate
ls -1 /data/adb/apps | while read -r PROC; do
     # export current PROC
     export PROC

    if [ ! -f "/data/adb/apps/$PROC/disable" ];then

        logme stats "loop(): calling manager.sh for $PROC"
        # call manager.sh
        "$MODDIR"/manager.sh disableRestart disableNotificaitons

        # verify mountpoint
        if mount | grep -q "$PROC";then
            # shellcheck disable=SC2059
            printf "\n$PROC" >> "$mountedAppList"
        fi
    else
        logme stats "loop(): skipping $PROC, disable tag found"
    fi

done

# re-init logger_setup that was modified inside the while loop.
logger_setup


# remove bootscript tag
rm -f "$MODDIR/bootscript"

# get mounted app list
mountedAppList=$(cat "$mountedAppList")
# remove list
rm -f "$mountedAppList"

# notify
logme stats "done boot-service!"

# send notificatons to user
if [ "$mountedAppList" != "" ];then
    send_notification "Successfully Mounted$mountedAppList"
fi

# exit clean-up
logger_check