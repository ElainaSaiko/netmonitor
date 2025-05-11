#! /bin/bash

# 设置工作目录
WORK_DIR=$(cd "$(dirname "$0")" && pwd)

# mysql数据库连接信息
source $WORK_DIR/../db.info
export MYSQL_PWD=$DB_PASS

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

# 检查数据库是否可连接
function checkmysql() {
    if (mysql -h$DB_HOST -u$DB_USER $DB_NAME -e "SHOW DATABASES;" > /dev/null 2>&1); then
        console_log "ok" "mysql service ready now."
    else
        console_log "error" "mysql service no ready or db.info error."
        exit 1
    fi
}

# 检查数据库是否存在
function checkdb() {
    if (mysql -h$DB_HOST -u$DB_USER $DB_NAME -e "SHOW TABLES;" > /dev/null 2>&1); then
        console_log "ok" "database "$DB_NAME" already esist. "
    else
        console_log "error" "database "$DB_NAME" doesn't exist."
        console_log "creating database "$DB_NAME" ..."
        if (mysql -h$DB_HOST -u$DB_USER -e \
            "CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" > /dev/null 2>&1); then
            console_log "ok" "done !"
        else
            console_log "error" "error,all in boom !"
            exit 1
        fi
    fi
}

# 检查表是否存在
function checktb() {
    for HOST in $(cat $WORK_DIR/../hosts.list); do 
        TABLE_NAME=${HOST//./_}_delayTime
        if (mysql -h$DB_HOST -u$DB_USER -e "SELECT 1 FROM ${DB_NAME}.${TABLE_NAME} LIMIT 1" > /dev/null 2>&1); then
            console_log "ok" "tABLE "$TABLE_NAME" already exist."
        else
            console_log "error" "table "$TABLE_NAME" doesn't exist. "
            console_log "creating table "$TABLE_NAME" ... "

            if (mysql -h$DB_HOST -u$DB_USER  $DB_NAME -e \
                "CREATE TABLE \`$TABLE_NAME\` (\
                    \`timestamp\` int(11) NOT NULL, \
                    \`loss\` float NULL DEFAULT NULL, \
                    \`min\` float NULL DEFAULT NULL, \
                    \`avg\` float NULL DEFAULT NULL, \
                    \`max\` float NULL DEFAULT NULL, \
                    PRIMARY KEY (\`timestamp\`)\
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;") > /dev/null 2>&1; then
                console_log "ok" "done !"
            else
                console_log "error" "error,all in boom !"
            fi
        fi
    done
}

if [ -z "$1" ]; then
    console_log "error" "invalid parameter"
    exit 1
fi

case $1 in
    "checkmysql")
        checkmysql
        ;;
    "checkdb")
        checkdb
        ;;
    "checktb")
        checktb
        ;;
    *)
        console_log "error" "Invalid parameter. Usage: $0 {checkmysql|checkdb|checktb}"
        exit 1 
esac
