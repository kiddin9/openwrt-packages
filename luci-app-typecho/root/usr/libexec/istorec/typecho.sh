#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get typecho.@main[0].port 2>/dev/null`
  local image_name=`uci get typecho.@main[0].image_name 2>/dev/null`
  local config=`uci get typecho.@main[0].config_path 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi
  [ -z "$image_name" ] && image_name="joyqi/typecho:nightly-php7.4"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f typecho

  [ -z "$port" ] && port=9080

  mkdir -p $config
  chmod 777 $config
  local cmd="docker run --restart=unless-stopped -d -h TypeChoServer -v \"$config:/app/usr\" "

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:80 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name typecho \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the typecho"
  echo "      upgrade                Upgrade the typecho"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the typecho"
  echo "      status                 TypeCho status"
  echo "      port                   TypeCho port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f typecho
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} typecho
  ;;
  "status")
    docker ps --all -f 'name=typecho' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=typecho' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->9080/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
