#!/system/bin/sh
# shellcheck shell=bash
# * this file is meant to be sourced only
# * moudule for logging

# check MODDIR definition
[ -z ${MODDIR+x} ] && {
    MODDIR="${0%/*}"
}

# check MODNAME definition
[ -z ${MODNAME+x} ] && {
    MODNAME="${MODDIR##*/}"
}

# check if logfile is defined
[ -z ${path_file_logs+x} ] && {
    # default to cache if not defined.
    export path_file_logs="/cache/module.log"
}

# check if config_debug
[ -z ${config_debug+x} ] && {
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

    [ -n ${logger_config_print_terminal+x} ] && logger_config_print_terminal=false

    [ -n "$1" ] && [ -n "$2" ] && {
        if { [ "$1" != "debug" ] || [ "$config_debug" = true ]; };then
            # check if logger global parameters are defined
            if { [ -n ${logger_process+x} ] && [ -n ${logger_special+x} ]; };then
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
            if { [ -n ${logger_process+x} ] && [ -n ${logger_special+x} ]; };then
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