#!/bin/bash 

print_usage () {
    echo -e "Usage:"
    echo -e "\t./backup.sh <[USER@HOST:]dir> <[USER@HOST:]backup-dir> [OPTIONS]* \n"
    echo -e "Options:"
    echo -e "\t-h | --help\t display this message"
    echo -e "\t--restore\t restore system from the given backup." 
    echo -e "\t--dry-run\t simulate the backup process"
}

parse_args() {
    if [[ $# -eq 0 ]]
    then
        print_usage
        exit
    fi

    dir="$1"
    shift
    backup_dir="$1"
    shift
    rsync_options=""
    restore=0

    while [[ $# -ne 0 ]]
    do
        case $1 in
            -h|--help)
                print_usage
                exit
                ;;
            --dry-run)
                rsync_options="${rsync_options} --dry-run"
                ;;
            --restore)
                restore=1
                ;;
        esac
        shift
    done

    export dir
    export backup_dir
    export rsync_options
    export restore
}

backup() {
    rsync -aAXv ${dir} ${backup_dir} \
        --exclude=/dev/* \
        --exclude=/proc/* \
        --exclude=/sys/* \
        --exclude=/tmp/* \
        --exclude=/run/* \
        --exclude=/mnt/* \
        --exclude=/media/* --exclude="swapfile" --exclude="lost+found" --exclude=".cache" \
        --exclude="Downloads" \
        ${rsync_options}
}

restore() { 
    rsync -aAXv ${backup_dir} ${dir} \
        --delete ${rsync_options}
}

parse_args $@

if [[ ${restore} -eq 0 ]]
then
    backup
else
    restore
fi
