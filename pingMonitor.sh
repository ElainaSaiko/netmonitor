#!/bin/bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# 设置工作目录
WORK_DIR=$(cd "$(dirname "$0")" && pwd)

# mysql数据库连接信息
source $WORK_DIR/../db.info
export MYSQL_PWD=$DB_PASS

# 获取当前时间
CURRENT_TIME=$(date +"%s")

# 使用 fping 批量检测主机
RESULTS=$(fping -4 -c10 -f $WORK_DIR/../hosts.list -q 2>&1)
if [[ ! "$RESULTS" =~ "xmt/rcv/%loss" ]]; then
    echo "$RESULTS"
    exit 1
fi

echo "$RESULTS" | while read LINE; do
    HOST=$(echo $LINE | awk '{print $1}')
    TABLE_NAME=${HOST//./_}_delayTime

    # 提取各个字段
    LOSS=$(echo $LINE | awk -F '[/%]' '{print $6}')

    if [[ "$LINE" =~ "min/avg/max" ]]; then
        MIN=$(echo $LINE | awk -F '[/[:space:]]+' '{print $14}' )
        AVG=$(echo $LINE | awk -F '[/]' '{print $8}')
        MAX=$(echo $LINE | awk -F '[/]' '{print $9}')
    else
        MIN=9999
        AVG=9999
        MAX=9999
    fi

    mysql -h$DB_HOST -u$DB_USER $DB_NAME -e \
    "INSERT INTO $TABLE_NAME (timestamp, loss, min, avg, max)\
     VALUES ($CURRENT_TIME, $LOSS, $MIN, $AVG, $MAX);" > /dev/null 2>&1
done