#!/bin/bash
#
# Installs dependencies for this project
#
# Usage:
#     ./install.sh <-t>
#
# Options:
#     -t Pipe output logs to a file (tee)
#
# +------------------------------------------------------+
# | Who          | Date       | Version | Comments       |
# | Chris Hommel | 23-03-2025 | 1       | Initial set up |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# |              |            |         |                |
# +------------------------------------------------------+

set -e
set -o pipefail

PIPE_TO_FILE=0
LOG_FILE="./install-log.txt"

write_options(){
    write_log "Options:"
    write_log "    <-t> Pipe output to file"
    write_log "    <-?> Print options"
}

write_log(){
    if [ $PIPE_TO_FILE -eq 1 ]; then
        echo "$1" >> "$LOG_FILE"
    else
        echo "$1"
    fi
}

write_error(){
    local message="$1"
    write_log "$message"
    local length=${#message}
    local line=$(printf '%*s' "$length" '' | tr ' ' '^')
    write_log "$line"
}

parse_args(){
    for arg in "$@"; do
        case "$arg" in
            -t)
            write_log "Pipe to file turned on, writing to $LOG_FILE"
            PIPE_TO_FILE=1
            ;;
            -?)
            write_options
            ;;
            *)
            write_options
            ;;
        esac
    done

    write_log "Starting install"
    return 0
}

parse_args "$@"

copy_tmux() {
    if [ -f ~/.tmux.conf ]; then
        write_log "Removing tmux"
        rm ~/.tmux.conf
    fi

    write_log "Setting up .tmux.conf"
    cp "./.tmux.conf" ~/.tmux.conf

    return 0
}


reload_tmux() {
    if tmux list-sessions &>/dev/null; then
        write_log "Killing Current tmux sessions"
        tmux kill-server
    fi

    write_log "Reloading tmux"
    tmux start-server
    tmux source-file ~/.tmux.conf

    return 0
}


install_tmux(){
    copy_tmux
    reload_tmux

    return 0
}

install_profile(){
    if [ -f ~/.profile ]; then
        write_log "Removing profile"
        rm ~/.profile
    fi

    write_log "Setting up .profile"
    cp "./.profile" ~/.profile

    return 0;
}

install_bash_rc(){
    if [ -f ~/.bashrc ]; then
        write_log "Removing bashrc"
        rm ~/.bashrc
    fi

    write_log "Setting up .bashrc"
    cp "./.bashrc" ~/.bashrc

    return 0;
}

install_git(){
    if [ -f ~/.gitconfig ]; then
        write_log "Removing gitconfig"
        rm ~/.gitconfig
    fi

    write_log "Setting up .gitconfig"
    cp "./.gitconfig" ~/.gitconfig

    return 0;
}

reload_source(){
    source ~/.profile
    source ~/.bashrc

    return 0
}

main(){
    install_profile
    install_bash_rc
    install_git
    install_tmux

    reload_source
    return 0
}

main