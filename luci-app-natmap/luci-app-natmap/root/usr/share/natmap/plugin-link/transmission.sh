#!/bin/bash

# NATMap
outter_ip=$1
outter_port=$2
inner_port=$4
protocol=$5

LINK_TR_RPC_URL=$(echo $LINK_TR_RPC_URL | sed 's/\/$//')
url="$LINK_TR_RPC_URL/transmission/rpc"
# update port
trauth="-u $LINK_TR_USERNAME:$LINK_TR_PASSWORD"

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
# # 获取trsid，直至重试次数用尽
trsid=""
retry_count=0

for ((retry_count = 0; retry_count <= max_retries; retry_count++)); do
    trsid=$(curl -s $trauth $url | sed 's/.*<code>//g;s/<\/code>.*//g')

    # Check if the provided session ID contains the header "X-Transmission-Session-Id"
    if [[ $trsid == *"X-Transmission-Session-Id"* ]]; then
        echo "$GENERAL_NAT_NAME - $LINK_MODE 登录成功" >>/var/log/natmap/natmap.log

        # Modify the port using the Transmission API
        tr_result=$(curl -s -X POST \
            -H "$trsid" $trauth \
            -d '{"method":"session-set","arguments":{"peer-port":'$outter_port'}}' \
            "$url")

        # Check if the port modification was successful
        if [[ $(echo "$tr_result" | jq -r '.result') == "success" ]]; then
            echo "transmission port modified successfully" >>/var/log/natmap/natmap.log
            break
        else
            echo "transmission Failed to modify the port" >>/var/log/natmap/natmap.log
            # Sleep for a specified amount of time
            sleep $sleep_time
        fi
    else
        # Sleep for a specified amount of time
        sleep $sleep_time
    fi

    # Sleep for a specified amount of time
    sleep $sleep_time
done

if [ $retry_count -eq $max_retries ]; then
    echo "$GENERAL_NAT_NAME - $LINK_MODE 达到最大重试次数，无法修改" >>/var/log/natmap/natmap.log
    exit 1
fi
