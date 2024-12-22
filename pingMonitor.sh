#!/bin/bash
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
# 获取当前时间
CURRENT_TIME=$(($(date +"%s")-1))
# 获取当前脚本目录
WORK_DIR=$(cd "$(dirname "$0")" && pwd)

# 检测数据库
sh $WORK_DIR/checkDatabase.sh

# MySQL数据库连接信息
DB_USER="root"
DB_PASS=""
DB_NAME="netMonitor"

# 使用 fping 批量检测主机
fping -4 -c10 --file=$WORK_DIR/hosts.list -q 2>&1 | \
awk -F'[:=]' '{split($NF, delay, "/"); avg_delay = delay[2]; if (avg_delay == "" || avg_delay == "0") { avg_delay = "9999"; } print $1, avg_delay }' | \
while read TARGET_HOST AVG_DELAY; do
    # 去除主机名两边的空格
    TARGET_HOST=$(echo $TARGET_HOST | xargs)
    # 将主机名中的 "." 替换为 "_"
    TABLE_NAME=${TARGET_HOST//./_}_delayTime
    # 连接到 MySQL 数据库并插入数据
    mysql -u$DB_USER -p$DB_PASS -e "INSERT INTO $TABLE_NAME (timestamp, delayTime) VALUES ('$CURRENT_TIME', '$AVG_DELAY')" $DB_NAME
done

echo "Ping results written to database successfully!"
