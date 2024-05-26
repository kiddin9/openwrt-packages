#!/bin/bash

title="natmap - ${GENERAL_NAT_NAME} 更新"
desp="$1"

# 拼装post数据
postdata="title=$title&desp=$desp"
message=(
    "--header" "Content-type: application/x-www-form-urlencoded"
    "--data" "$postdata"
)

# 获取url
url=""
if [ "${NOTIFY_SERVERCHAN_ADVANCED_ENABLE}" == 1 ] && [ -n "$NOTIFY_SERVERCHAN_ADVANCED_URL" ]; then
    url="$NOTIFY_SERVERCHAN_ADVANCED_URL/${NOTIFY_SERVERCHAN_SENDKEY}.send"
else
    url="https://sctapi.ftqq.com/${NOTIFY_SERVERCHAN_SENDKEY}.send"
fi
# 默认重试次数为1，休眠时间为3s
max_retries=1
sleep_time=3

# 判断是否开启高级功能
if [ "${NOTIFY_ADVANCED_ENABLE}" == 1 ] && [ -n "$NOTIFY_ADVANCED_MAX_RETRIES" ] && [ -n "$NOTIFY_ADVANCED_SLEEP_TIME" ]; then
    # 获取最大重试次数
    max_retries=$((NOTIFY_ADVANCED_MAX_RETRIES == "0" ? 1 : NOTIFY_ADVANCED_MAX_RETRIES))
    # 获取休眠时间
    sleep_time=$((NOTIFY_ADVANCED_SLEEP_TIME == "0" ? 3 : NOTIFY_ADVANCED_SLEEP_TIME))
fi

for ((retry_count = 1; retry_count <= max_retries; retry_count++)); do
    result=$(curl -X POST -s -o /dev/null -w "%{http_code}" "$url" "${message[@]}")
    if [ $result -eq 200 ]; then
        echo "$GENERAL_NAT_NAME - $NOTIFY_MODE 发送成功" >>/var/log/natmap/natmap.log
        break
    else
        echo "$NOTIFY_MODE 登录失败,休眠$sleep_time秒" >>/var/log/natmap/natmap.log
        sleep $sleep_time
    fi
done

# Check if maximum retries reached
if [ $retry_count -eq $max_retries ]; then
    echo "$GENERAL_NAT_NAME - $NOTIFY_MODE 达到最大重试次数，无法通知" >>/var/log/natmap/natmap.log
    break
fi
