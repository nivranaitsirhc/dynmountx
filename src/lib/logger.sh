#!/system/bin/sh
# shellcheck shell=bash
# * this file is meant to be sourced only
# * moudule for logging

# check if moddir is defined
[[ ! -v MODDIR ]] && {
    MODDIR="${0%/*}"
    MODNAME="${MODDIR##*/}"
}

# check if logfile is defined
[[ ! -v path_file_logs ]] && {
    [ ! -d "$MODDIR/logs" ] && mkdir -p "$MODDIR/logs"
    path_file_logs="$MODDIR/logs/module.log"
}

# check if config_dubg
[[ ! -v config_debug ]] && {
    config_debug=true
}

logme() {
    # 1 - {06} stats,error,debug
    # 2 - {18} stage or process (optional)
    # 3 - {XX} message

    if [ "$1" != "debug" ] || [ "$config_debug" = true ]; then
        if [ -n "$3" ];then 
            # printf "%s %8s %8s %8s  %-6s : %-18s --> $2\n" "$(date)" "$UID" "$PID" "$$" "$1" "$STAGE" >> "$path_file_logs"
            printf "%s %-6s : %-18s --> $3\n" "$(date)" "$1" "$2" >> "$path_file_logs"
            printf "%s %-6s : %-18s --> $3\n" "$(date)" "$1" "$2"
        else 
            printf "%s %-6s --> $2\n" "$(date)" "$1" >> "$path_file_logs"
            printf "%s %-6s --> $2\n" "$(date)" "$1"
        fi
    fi
    return 0
}

LOGER_MODULE="loaded"