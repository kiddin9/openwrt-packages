#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get navidrome.@main[0].http_port 2>/dev/null`
  local image_name=`uci get navidrome.@main[0].image_name 2>/dev/null`
  local config=`uci get navidrome.@main[0].config_path 2>/dev/null`
  local content=`uci get navidrome.@main[0].music_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="difegue/navidrome"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f navidrome

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=4533

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/data\" \
    -v \"$content:/music:ro\" \
    --dns=172.17.0.1 \
    -p $http_port:4533 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name navidrome \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the navidrome"
  echo "      upgrade                Upgrade the navidrome"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the navidrome"
  echo "      status                 Navidrome status"
  echo "      port                   Navidrome port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f navidrome
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} navidrome
  ;;
  "status")
    docker ps --all -f 'name=navidrome' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=navidrome' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
