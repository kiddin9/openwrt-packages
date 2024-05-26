#!/bin/bash

# NATMap
outter_ip=$1
outter_port=$2
ip4p=$3

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
retry_count=0
dns_type="AAAA"
dns_record=""
dns_record_id=""

# 获取cloudflare dns记录的dns_record
for (( ; retry_count < max_retries; retry_count++)); do
  dns_record=$(curl --request GET \
    --url https://api.cloudflare.com/client/v4/zones/$LINK_CLOUDFLARE_ZONE_ID/dns_records?name=$LINK_CLOUDFLARE_DDNS_DOMAIN \
    --header "Authorization: Bearer $LINK_CLOUDFLARE_TOKEN" \
    --header 'Content-Type: application/json')

  # 判断是否成功获取响应
  if [ "$(echo "$dns_record" | jq '.success' | sed 's/"//g')" == "true" ]; then
    # 获取与dns_type匹配的dns_record_id
    dns_record_num=$(echo "$dns_record" | jq '.result_info.count')
    for ((i = 0; i < $dns_record_num; i++)); do
      if [ "$(echo "$dns_record" | jq ".result[$i].type" | sed 's/"//g')" == "$dns_type" ]; then
        dns_record_id=$(echo "$dns_record" | jq ".result[$i].id" | sed 's/"//g')
        echo "$GENERAL_NAT_NAME - $LINK_MODE 登录成功" >>/var/log/natmap/natmap.log
        break
      fi
    done
    break
  else
    echo "$GENERAL_NAT_NAME - $LINK_MODE 登录失败,休眠$sleep_time秒" >>/var/log/natmap/natmap.log
    sleep $sleep_time
  fi
done

# 判断是否成功获得dns_record_id
# 如果$dns_record_id不为空，则创建cloudflare的dns记录
if [ ! -z "$dns_record_id" ]; then
  # 更新cloudflare的dns记录
  request_data="{\"type\":\"$dns_type\",\"name\":\"$LINK_CLOUDFLARE_DDNS_DOMAIN\",\"content\":\"$ip4p\",\"ttl\":60,\"proxied\":false}"

  for (( ; retry_count < max_retries; retry_count++)); do
    result=$(
      curl --request PUT \
        --url https://api.cloudflare.com/client/v4/zones/$LINK_CLOUDFLARE_ZONE_ID/dns_records/$dns_record_id \
        --header "Authorization: Bearer $LINK_CLOUDFLARE_TOKEN" \
        --header 'Content-Type: application/json' \
        --data "$request_data"
    )

    # 判断api是否调用成功,返回参数success是否为true
    if [ "$(echo "$result" | jq '.success' | sed 's/"//g')" == "true" ]; then
      echo "$GENERAL_NAT_NAME - $LINK_MODE 更新成功" >>/var/log/natmap/natmap.log
      break
    else
      echo "$GENERAL_NAT_NAME - $LINK_MODE 修改失败,休眠$sleep_time秒" >>/var/log/natmap/natmap.log
      sleep $sleep_time
    fi
  done
else
  echo "$GENERAL_NAT_NAME - $LINK_MODE 始终登录失败或不存在相应DNS记录" >>/var/log/natmap/natmap.log
  exit 1
fi

# Check if maximum retries reached
if [ $retry_count -eq $max_retries ]; then
  echo "$GENERAL_NAT_NAME - $LINK_MODE 达到最大重试次数，无法修改" >>/var/log/natmap/natmap.log
  exit 1
fi
