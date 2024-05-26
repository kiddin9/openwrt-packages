#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get mtphotos.@main[0].port 2>/dev/null`
  local image_name=`uci get mtphotos.@main[0].image_name 2>/dev/null`
  local config=`uci get mtphotos.@main[0].config_path 2>/dev/null`
  local upload=`uci get mtphotos.@main[0].upload_path 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi

  [ -z "$image_name" ] && image_name="mtphotos/mt-photos:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f mtphotos

  [ -z "$port" ] && port=8063

  local cmd="docker run --restart=unless-stopped -d -h MTPhotosServer \
    -v \"$upload:/upload\" \
    -v \"$config:/config\" "

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:8063 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name mtphotos \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the mtphotos"
  echo "      upgrade                Upgrade the mtphotos"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the mtphotos"
  echo "      status                 MTPhotos status"
  echo "      port                   MTPhotos port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f mtphotos
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} mtphotos
  ;;
  "status")
    docker ps --all -f 'name=mtphotos' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=mtphotos' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->8063/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
