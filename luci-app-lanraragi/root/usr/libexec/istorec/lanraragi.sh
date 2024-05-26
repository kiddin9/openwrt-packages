#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get lanraragi.@main[0].http_port 2>/dev/null`
  local image_name=`uci get lanraragi.@main[0].image_name 2>/dev/null`
  local config=`uci get lanraragi.@main[0].config_path 2>/dev/null`
  local content=`uci get lanraragi.@main[0].content_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="dezhao/lanraragi_cn"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f lanraragi

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=3000

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/root/lanraragi/database\" \
    -v \"$content:/root/lanraragi/content\" \
    --dns=172.17.0.1 \
    -p $http_port:3000 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name lanraragi \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the lanraragi"
  echo "      upgrade                Upgrade the lanraragi"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the lanraragi"
  echo "      status                 LANraragi status"
  echo "      port                   LANraragi port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f lanraragi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} lanraragi
  ;;
  "status")
    docker ps --all -f 'name=lanraragi' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=lanraragi' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
