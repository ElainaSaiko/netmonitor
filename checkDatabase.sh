#! /bin/bash

# 获取当前脚本目录
WORK_DIR=$(cd "$(dirname "$0")" && pwd)

# MySQL数据库连接信息
DB_USER="root"
DB_PASS=""
DB_NAME="netMonitor"

# 检查表是否存在
for i in $(cat $WORK_DIR/hosts.list)
    do 
    TABLE_NAME=${i//./_}_delayTime
    mysql -u$DB_USER -p$DB_PASS -e "select 1 FROM ${DB_NAME}.${TABLE_NAME} LIMIT 1" > /dev/null 2>&1

    if [ $? -eq 0 ]; then
        echo -e  "\033[32m Table '$TABLE_NAME' already exist. \033[0m"
    else
        echo -e  "\\033[31m Table '$TABLE_NAME' doesn't exist. \033[0m"
        echo -e  "\033[32m Creating table '$TABLE_NAME'... \033[0m"
        mysql -u$DB_USER -p$DB_PASS  -e "CREATE TABLE \`$TABLE_NAME\` (\`timestamp\` int(11) NOT NULL,\`delayTime\` float NOT NULL,PRIMARY KEY (\`timestamp\`)) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci" $DB_NAME
        if [ $? -eq 0 ]; then
            echo -e  "\033[32m Done ! \033[0m"
        else
            echo -e  "\033[31m Error,all in boom ! \033[0m"
        fi
    fi
done
