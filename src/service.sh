#!/system/bin/sh
# shellcheck shell=bash
# shellcheck source=/dev/null

# magisk_module required
MODDIR="${0%/*}"
# MODNAME="${MODDIR##*/}"

MAGISKTMP=$(magisk --path) || MAGISKTMP=/sbin

MIRROR="$MAGISKTMP/.magisk/mirror"

# logger library required variables
# -----------------------
[[ -v STAGE ]]  || export STAGE=boot-service
# [[ -v PROC ]]   || export PROC=magisk
[[ -v UID ]]    || { UID=$(id -g) && export UID; }
[[ -v PID ]]    || export PID=$$

# logger dummy function
logme(){ :; }

# source logger from lib
[ -d "$MODDIR/lib" ] && {
    # logger
    [ -f "$MODDIR/lib/logger.sh" ] && . "$MODDIR/lib/logger.sh"
}

# logger configs
logger_process=$(printf "%-6s %-6s" "$UID" "$PID")
logger_special=$(printf "%-18s - %s" "$(basename "$0"):$STAGE" "$PROC")
# logger
logger_check(){
    if [[ -v LOGGER_MODULE ]] && [ -f "$path_dir_storage/debug" ]; then
        [ -f "$path_file_logs" ] && {
            cat "$path_file_logs" >> "$path_dir_storage/module.log"
            printf "" > "$path_file_logs"
        }
    fi
}


# itirate the /data/adb/app
# run manager.sh with disabled restart me
[ ! -d "/data/adb/apps" ] && {
    logme stats "exiting.. unable to find /data/adb/apps"
    logger_check
    return 1
}

find /data/adb/apps -type d -mindepth 1 -maxdepth 1 -printf '%f\n' | while read -r PROC; do
    if [ ! -f "/data/adb/apps/$PROC/disable" ];then
        "$MODDIR/manager.sh" disableRestart
    else
        logme stats "loop(): skipping $PROC, disable tag found"
    fi
done

logsme stats "done boot-script"
logger_check