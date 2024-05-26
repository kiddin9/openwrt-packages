#!/bin/bash
# ikuai_version=3.7.6

# natmap
outter_ip=$1
outter_port=$2
ip4p=$3
inner_port=$4
protocol=$5

## ikuai参数获取
# lan_port
mapping_lan_port=""
# 如果$FORWARD_TARGET_PORT为空或者$FORWARD_TARGET_PORT为0则退出
if [ -z "${FORWARD_TARGET_PORT}" ] || [ "${FORWARD_TARGET_PORT}" -eq 0 ]; then
  echo "FORWARD_TARGET_PORT is empty,set to outter_port" >>/var/log/natmap/natmap.log
  mapping_lan_port=$outter_port
else
  mapping_lan_port=${FORWARD_TARGET_PORT}
fi

# login api and call api
ikuai_login_api="/Action/login"
ikuai_call_api="/Action/call"
call_url="$(echo $FORWARD_IKUAI_WEB_URL | sed 's/\/$//')${ikuai_call_api}"
login_url="$(echo $FORWARD_IKUAI_WEB_URL | sed 's/\/$//')${ikuai_login_api}"

# 浏览器headers
headers='{"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36",
    "Accept": "application/json",
    "Content-type": "application/json;charset=utf-8",
    "Accept-Language": "zh-CN"}'

# 登录ikuai
# This function performs the login action
# Parameters:
#   - login_username: username for login
#   - login_password: password for login
function login_action() {
  local login_username="$1"
  local login_password="$2"

  # Calculate the MD5 hash value of the password and convert it to hexadecimal
  local passwd=$(echo -n "$login_password" | openssl dgst -md5 -hex | awk '{print $2}')

  # Concatenate 'salt_11' and the password, and encode it using base64
  local pass=$(echo -n "salt_11$passwd" | openssl enc -base64)

  # Create the JSON payload for the login request
  local login_params='{
    "username": "'"$login_username"'",
    "passwd": "'"$passwd"'",
    "pass": "'"$pass"'",
    "remember_password": ""
  }'

  # Send the login request, extract the session ID (cookie) from the response headers, and store it in a variable
  local login_cookie=$(curl -s -D - -H "$headers" -X POST -d "$login_params" "$login_url" | awk -F' ' '/Set-Cookie:/ {print $2}')

  # echo the login_cookie
  echo "$login_cookie"
}

# 查询端口映射
# Function to show the mapping action
# Parameters:
#   - show_cookie: Cookie value for authentication
#   - show_comment: Comment to filter the results
function show_mapping_action() {
  local show_cookie="$1"
  local show_comment="$2"
  # Construct the payload for the API request
  local show_payload='{
    "func_name": "dnat",
    "action": "show",
    "param": {
      "FINDS": "lan_addr,lan_port,wan_port,comment",
      "KEYWORDS": "'"$show_comment"'",
      "TYPE": "total,data",
      "limit": "0,20",
      "ORDER_BY": "",
      "ORDER": ""
    }
  }'

  # Send the API request and store the response in show_result variable
  local show_result=$(curl -s -X POST -H "$headers" -b "$show_cookie" -d "$show_payload" "$call_url")
  # Extract the show_ids from the response using jq
  local show_ids=$(echo "$show_result" | jq -r '.Data.data[].id')

  # echo the show_ids
  # echo "${show_ids[@]}"
  for id in "${show_ids[@]}"; do
    echo "$id"
  done
}

# 删除端口映射
# Deletes a mapping action
# Arguments:
#   - del_cookie: The cookie used for authentication
#   - del_ids: An array of DNAT IDs to be deleted
function del_mapping_action() {
  local del_cookie="$1"
  local del_id="$2"
  # Declare an empty array to store the delete response
  local del_result=""

  # Construct the payload for the delete request.
  local del_payload='{
      "func_name": "dnat",
      "action": "del",
      "param": {
        "id": "'"$del_id"'"
      }
    }'

  # Send the delete request using cURL and store the response.
  del_response=$(curl -s -X POST -H "$headers" -b "$del_cookie" -d "$del_payload" "$call_url")
  # echo "del_ids: $del_ids"
  # echo "del_response: $del_response"
}

# 增加端口映射
# Function to add a mapping action
# Parameters:
#   - add_cookie - The cookie for authentication
#   - add_comment - The comment for the mapping action
function add_mapping_action() {
  local add_cookie="$1"
  local add_comment="$2"
  local enabled="yes"

  # Create the payload JSON object
  local add_payload='{
    "func_name": "dnat",
    "action": "add",
    "param": {
      "enabled": "'"$enabled"'",
      "comment": "'"$add_comment"'",
      "interface": "'"$FORWARD_IKUAI_MAPPING_WAN_INTERFACE"'",
      "lan_addr": "'"$FORWARD_TARGET_IP"'",
      "protocol": "'"$FORWARD_IKUAI_MAPPING_PROTOCOL"'",
      "wan_port": "'"$GENERAL_BIND_PORT"'",
      "lan_port": "'"$mapping_lan_port"'",
      "src_addr": ""
    }
  }'

  # Send the POST request to the specified URL with the payload
  local add_result=$(curl -s -X POST -H "$headers" -b "$add_cookie" -d "$add_payload" "$call_url")

  # Output the result
  echo "$add_result"
}

# 初始化参数
# cookie
cookie=""
# 端口映射id
dnat_ids=()
# 端口映射备注，区分不同的端口映射，查询时使用，唯一，不可重复
comment="natmap-${GENERAL_NAT_NAME}"

# 默认重试次数为1，休眠时间为3s
max_retries=1
sleep_time=3
retry_count=0

# 判断是否开启高级功能
if [ "${FORWARD_ADVANCED_ENABLE}" == 1 ] && [ -n "$FORWARD_ADVANCED_MAX_RETRIES" ] && [ -n "$FORWARD_ADVANCED_SLEEP_TIME" ]; then
  # 获取最大重试次数
  max_retries=$((FORWARD_ADVANCED_MAX_RETRIES == "0" ? 1 : FORWARD_ADVANCED_MAX_RETRIES))
  # 获取休眠时间
  sleep_time=$((FORWARD_ADVANCED_SLEEP_TIME == "0" ? 3 : FORWARD_ADVANCED_SLEEP_TIME))
fi

# 端口映射处理开始
for ((retry_count = 0; retry_count <= max_retries; retry_count++)); do
  # 登录
  cookie=$(login_action "$FORWARD_IKUAI_USERNAME" "$FORWARD_IKUAI_PASSWORD")
  # echo "cookie: $cookie"

  if [ -n "$cookie" ]; then
    # echo "$GENERAL_NAT_NAME - $FORWARD_MODE 登录成功"

    # 查询端口映射id
    dnat_ids=($(show_mapping_action "$cookie" "$comment"))
    # echo "dnat_ids: ${dnat_ids[@]}"

    # 删除端口映射
    for dnat_id in "${dnat_ids[@]}"; do
      del_mapping_action "$cookie" "$dnat_id"
    done

    # 再次查询端口映射id
    dnat_ids=($(show_mapping_action "$cookie" "$comment"))

    # 验证对应端口映射是否全部删除
    if [ ${#dnat_ids[@]} -eq 0 ]; then
      echo "$GENERAL_NAT_NAME - $FORWARD_MODE Port mapping deleted successfully"

      # 添加端口映射
      add_response=$(add_mapping_action "$cookie" "$comment")
      # Check if the modification was successful
      if [ "$(echo "$add_response" | jq -r '.ErrMsg')" = "Success" ]; then
        echo "$GENERAL_NAT_NAME - $FORWARD_MODE Port mapping modified successfully" >>/var/log/natmap/natmap.log
        break
      else
        echo "$GENERAL_NAT_NAME - $FORWARD_MODE Failed to modify the port mapping" >>/var/log/natmap/natmap.log
      fi
    else
      echo "$GENERAL_NAT_NAME - $FORWARD_MODE Failed to delete the port mapping" >>/var/log/natmap/natmap.log
    fi
  fi
  echo "$GENERAL_NAT_NAME - $FORWARD_MODE 修改失败,休眠$sleep_time秒" >>/var/log/natmap/natmap.log
  sleep $sleep_time
done

# Check if maximum retries reached
if [ $retry_count -eq $max_retries ]; then
  echo "$GENERAL_NAT_NAME - $FORWARD_MODE 达到最大重试次数，无法修改" >>/var/log/natmap/natmap.log
  exit 1
fi
