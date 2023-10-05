#!/system/bin/sh
# shellcheck shell=ash
# * this file is meant to be sourced only
# * moudule for logging

# check MODDIR definition
[ -z "${MODDIR+x}" ] && {
    MODDIR="${0%/*}"
}

# check MODNAME definition
[ -z "${MODNAME+x}" ] && {
    MODNAME="${MODDIR##*/}"
}

# check if logfile is defined
[ -z "${path_file_logs+x}" ] && {
    # default to cache if not defined.
    export path_file_logs="/cache/module.log"
}

# check if config_debug
[ -z "${config_debug+x}" ] && {
    # default to debug true if not defined.
    config_debug=true
}

logme() {
    # param 1 - {06}                            -> tags(max 6 chars): stats,error,debug, etc..
    # param 2 - {XX}                            -> message.......

    # ------------------------------------
    # * global formatting parameters. 
    # * note: must be both declared
    # logger_process={string}                   -> Mostly PID, UID, etc..
    # logger_special={string}{18padded_char}    -> script name, process name, etc..
    
    # ------------------------------------
    # * Print to terminal
    # logger_config_print_terminal={true/false} -> default to false if not defined
    # 


    [ -z "${logger_config_print_terminal+x}" ] && logger_config_print_terminal=false

    # With Tag Enabled Log
    # $1 -> tag 
    # $2 -> message
    if [ -n "$1" ] && [ -n "$2" ];then
        if { [ "$1" != "debug" ] || [ "$config_debug" = true ]; };then
            # check for logger global formatting parameters definition
            if { [ -n "${logger_process+x}" ] && [ -n "${logger_special+x}" ]; };then
                # with formatting
                printf "%s %s %-6s : %s --> %s\n" "$(date)" "$logger_process" "$1" "$logger_special" "$2" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %s %-6s : %s --> %s\n" "$(date)" "$logger_process" "$1" "$logger_special" "$2"
            else
                # default; without formatting
                printf "%s %-6s --> %s\n" "$(date)" "$1" "$2" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %-6s --> %s\n" "$(date)" "$1" "$2"
            fi
        fi
    # Without Tag Enabled Log
    # $1 -> tag/message
    # $2 -> Empty
    elif [ -n "$1" ] && [ -z "$2" ]; then
        if [ "$1" != "debug" ] || [ "$config_debug" = true ];then
            if { [ -n "${logger_process+x}" ] && [ -n "${logger_special+x}" ]; };then
                printf "%s %s : %s --> %s\n" "$(date)" "$logger_process" "$logger_special" "$1" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %s : %s --> %s\n" "$(date)" "$logger_process" "$logger_special" "$1"
            else 
                printf "%s --> %s\n" "$(date)" "$1" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s --> %s\n" "$(date)" "$1"
            fi
        fi
    fi
    return 0
}

# shellcheck disable=SC2034
LOGGER_MODULE="loaded"