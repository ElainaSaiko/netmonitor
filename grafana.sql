SELECT FROM_UNIXTIME(timestamp), delayTime 
FROM (
    SELECT timestamp, delayTime 
    FROM netMonitor.www_baidu_com_delayTime
    ORDER BY timestamp DESC 
    LIMIT 1440
) AS latest_data 
ORDER BY timestamp ASC;
