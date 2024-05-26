#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get memos.@main[0].http_port 2>/dev/null`
  local image_name=`uci get memos.@main[0].image_name 2>/dev/null`
  local config=`uci get memos.@main[0].config_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="neosmemo/memos:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f memos

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  # not conflict with jellyfin
  [ -z "$http_port" ] && http_port=5230

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/var/opt/memos\" \
    --dns=172.17.0.1 \
    -p $http_port:5230 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name memos \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the memos"
  echo "      upgrade                Upgrade the memos"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the memos"
  echo "      status                 Memos status"
  echo "      port                   Memos port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f memos
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} memos
  ;;
  "status")
    docker ps --all -f 'name=memos' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=memos' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
