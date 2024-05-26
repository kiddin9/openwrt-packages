#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get vaultwarden.@main[0].http_port 2>/dev/null`
  local notify_port=`uci get vaultwarden.@main[0].notify_port 2>/dev/null`
  local image_name=`uci get vaultwarden.@main[0].image_name 2>/dev/null`
  local config=`uci get vaultwarden.@main[0].config_path 2>/dev/null`
  local admin_token=`uci get vaultwarden.@main[0].admin_token 2>/dev/null`
  local signup_allowed=`uci get vaultwarden.@main[0].signup_allowed 2>/dev/null`

  [ -z "$image_name" ] && image_name="vaultwarden/server:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f vaultwarden

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=8002

  local cmd="docker run --restart=unless-stopped -d \
    --dns=172.17.0.1 \
    -p $http_port:80 \
    -v \"$config:/data\""

  [ -z "$notify_port" ] || cmd="$cmd -e \"-e WEBSOCKET_ENABLED=true\" -p $notify_port:3012"
  [ -z "$admin_token" ] || cmd="$cmd -e \"ADMIN_TOKEN=$admin_token\""
  if [ "$signup_allowed" = "1" ]; then 
    cmd="$cmd -e \"SIGNUPS_ALLOWED=true\""
  else
    cmd="$cmd -e \"SIGNUPS_ALLOWED=false\""
  fi

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name vaultwarden \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the vaultwarden"
  echo "      upgrade                Upgrade the vaultwarden"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the vaultwarden"
  echo "      status                 Vaultwarden status"
  echo "      port                   Vaultwarden port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f vaultwarden
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} vaultwarden
  ;;
  "status")
    docker ps --all -f 'name=vaultwarden' --format '{{.State}}'
  ;;
  "port")
    uci get -q vaultwarden.@main[0].http_port 2>/dev/null
  ;;
  *)
    usage
    exit 1
  ;;
esac
