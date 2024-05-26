#!/bin/bash

# NATMap
protocol=$5
inner_port=$4
outter_ip=$1
outter_port=$2
ip4p=$3

LINK_QB_WEB_URL=$(echo $LINK_QB_WEB_URL | sed 's/\/$//')

# 默认重试次数为1，休眠时间为3s
max_retries=1
sleep_time=3

# 判断是否开启高级功能
if [ "$LINK_ADVANCED_ENABLE" == 1 ] && [ -n "$LINK_ADVANCED_MAX_RETRIES" ] && [ -n "$LINK_ADVANCED_SLEEP_TIME" ]; then
    # 获取最大重试次数
    max_retries=$((LINK_ADVANCED_MAX_RETRIES == "0" ? 1 : LINK_ADVANCED_MAX_RETRIES))
    # 获取休眠时间
    sleep_time=$((LINK_ADVANCED_SLEEP_TIME == "0" ? 3 : LINK_ADVANCED_SLEEP_TIME))
fi

# 初始化参数
# 获取qbcookie，直至重试次数用尽
qbcookie=""
retry_count=0

for ((retry_count = 0; retry_count < max_retries; retry_count++)); do
    # 获取qbcookie
    qbcookie=$(
        curl -Ssi -X POST \
            -d "username=$LINK_QB_USERNAME&password=$LINK_QB_PASSWORD" \
            "$LINK_QB_WEB_URL/api/v2/auth/login" |
            sed -n 's/.*\(SID=.\{32\}\);.*/\1/p'
    )

    # 如果qbcookie为空，则重试
    if [ -z "$qbcookie" ]; then
        echo "$GENERAL_NAT_NAME - $LINK_MODE 登录失败,正在重试..." >>/var/log/natmap/natmap.log
        sleep $sleep_time
    else
        echo "$GENERAL_NAT_NAME - $LINK_MODE 登录成功" >>/var/log/natmap/natmap.log
        # 修改端口
        curl -s -X POST \
            -b "$qbcookie" \
            -d 'json={"listen_port":"'$outter_port'"}' \
            "$LINK_QB_WEB_URL/api/v2/app/setPreferences"
        break
    fi
done

# Check if maximum retries reached
if [ $retry_count -eq $max_retries ]; then
    echo "$GENERAL_NAT_NAME - $LINK_MODE 达到最大重试次数，无法修改" >>/var/log/natmap/natmap.log
    exit 1
fi
