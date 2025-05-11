#! /bin/bash

WORK_DIR=$(cd "$(dirname "$0")" && pwd)

# 输出颜色
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

function console_log() {
    case $1 in 
        "ok")
            echo -e "$GREEN$2$RESET"
            ;;
        "error")
            echo -e "$RED$2$RESET"
            ;;
        *)
            echo -e "$1"
    esac
}

function console_help() {
    console_log "Usage: $0 [options...]"
    console_log " -a, --add     add a host to hosts.list."
    console_log " -c, --check   chek database"
    console_log " -d, --delete  delete a host from hosts.list."
    console_log " -h, --help    get help informations."
    console_log " -p, --ping    ping result to mysql."
    console_log " --cron        add ping monitor cron task."
}

function parameter_error() {
    console_log "error" "invalid parameter, use -h or --help to get helps."
}

if [ ! -f "$WORK_DIR/hosts.list" ]; then
    console_log "error" "file "$WORK_DIR/hosts.list" doesn't exist."
    exit 1
fi

if [ ! -f "$WORK_DIR/db.info" ]; then
    console_log "error" "file "$WORK_DIR/db.info" doesn't exist."
    exit 1
fi

if [ ! -f "$WORK_DIR/scripts/checkDatabase.sh" ]; then
    console_log "error" "script "$WORK_DIR/scrpts/checkDatabase.sh" doesn't exist."
    exit 1
fi

if [ ! -f "$WORK_DIR/scripts/pingMonitor.sh" ]; then
    console_log "error" "script "$WORK_DIR/scripts/pingMonitor.sh" doesn't exist."
    exit 1
fi

if [ -z "$1" ]; then
    parameter_error
    exit 1
fi

case $1 in
    "-a"|"--add")
        if [ -z "$2" ]; then
            parameter_error
            exit 1
        fi
        if (grep -qw "$2" "$WORK_DIR/hosts.list"); then
            console_log "ok" "host $2 already exist."
            exit 0
        fi
        if (ping -4 -c 3 -w3 $2 > /dev/null 2>&1); then
            echo "$2" >> $WORK_DIR/hosts.list
            sh $WORK_DIR/scripts/checkDatabase.sh checktb
        else
            console_log "error" "host $2 type error or host $2 unreachable."
            exit 1
        fi
        ;;
    "-c"|"--check")
        sh $WORK_DIR/scripts/checkDatabase.sh checkmysql
        sh $WORK_DIR/scripts/checkDatabase.sh checkdb
        sh $WORK_DIR/scripts/checkDatabase.sh checktb
        ;;
    "-d"|"--delete")
        if [ -z "$2" ]; then
            parameter_error
            exit 1
        fi
        sed -i "/$2/d" $WORK_DIR/hosts.list
        ;;
    "-h"|"--help")
        console_help
        ;;
    "-p"|"--ping")
        sh $WORK_DIR/scripts/pingMonitor.sh
        ;;
    "--cron")
        echo "* * * * * root '$WORK_DIR/run.sh --ping > /dev/null 2>&1'" > /etc/cron.d/pingmonitor
        cat /etc/cron.d/pingmonitor
        systemctl restart crond
        ;;
    *)
        parameter_error
        exit 1
esac