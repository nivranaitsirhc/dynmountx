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
    # default to cache if not defined.
    export path_file_logs="/cache/module.log"
}

# check if config_debug
[[ ! -v config_debug ]] && {
    # default to debug true if not defined.
    config_debug=true
}

logme() {
    # $1 - {06} stats,error,debug, etc..
    # $2 - {XX} message
    # ------------------------------------
    # * global parameters. 
    # * note: must be both declared
    # ------------------------------------
    # logger_process={string}
    # logger_special={string}{18padded_char}
    # ------------------------------------
    # * config parameter
    # ------------------------------------
    # logger_config_print_terminal={false}

    [[ ! -v logger_config_print_terminal ]] && logger_config_print_terminal=false

    [ -n "$1" ] && [ -n "$2" ] && {
        if [ "$1" != "debug" ] || [ "$config_debug" = true ];then
            # check if logger global parameters are defined
            if [[ -v logger_process ]] && [[ -v logger_special ]];then
                printf "%s %s %-6s : %s --> %s\n" "$(date)" "$logger_process" "$1" "$logger_special" "$2" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %s %-6s : %s --> %s\n" "$(date)" "$logger_process" "$1" "$logger_special" "$2"
            else 
                printf "%s %-6s --> %s\n" "$(date)" "$1" "$2" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %-6s --> %s\n" "$(date)" "$1" "$2"
            fi
        fi
    }
    [ -n "$1" ] && [ -z "$2" ] && {
        if [ "$1" != "debug" ] || [ "$config_debug" = true ];then
            if [[ -v logger_process ]] && [[ -v logger_special ]];then
                printf "%s %s : %s --> %s\n" "$(date)" "$logger_process" "$logger_special" "$1" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s %s : %s --> %s\n" "$(date)" "$logger_process" "$logger_special" "$1"
            else 
                printf "%s --> %s\n" "$(date)" "$1" >> "$path_file_logs"
                [ "$logger_config_print_terminal" ] && \
                printf "%s --> %s\n" "$(date)" "$1"
            fi
        fi
    }
    return 0
}

LOGGER_MODULE="loaded"