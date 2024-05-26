#!/bin/bash

text="$1"
chat_id="${NOTIFY_TELEGRAM_BOT_CHAT_ID}"
token="${NOTIFY_TELEGRAM_BOT_TOKEN}"
title="natmap - ${GENERAL_NAT_NAME} 更新"

function curl_proxy() {
    if [ -z "$NOTIFY_TELEGRAM_BOT_PROXY" ]; then
        curl "$@"
    else
        curl -x $NOTIFY_TELEGRAM_BOT_PROXY "$@"
    fi
}

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

# # 判断是否开启高级功能
# if [ "$NOTIFY_ADVANCED_ENABLE" == 1 ]; then
#     # 获取最大重试次数
#     max_retries="${NOTIFY_ADVANCED_MAX_RETRIES%/:-$max_retries}"
#     # 获取休眠时间
#     sleep_time="${NOTIFY_ADVANCED_SLEEP_TIME%/:-$sleep_time}"
# fi

for ((retry_count = 1; retry_count <= max_retries; retry_count++)); do
    curl_proxy -4 -Ss -o /dev/null -X POST \
        -H 'Content-Type: application/json' \
        -d '{"chat_id": "'"${chat_id}"'", "text": "'"${title}\n\n${text}"'", "parse_mode": "HTML", "disable_notification": "false"}' \
        "https://api.telegram.org/bot${token}/sendMessage"
    status=$?
    if [ $status -eq 0 ]; then
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
    exit 1
fi
