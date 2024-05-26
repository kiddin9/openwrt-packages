#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get gogs.@main[0].http_port 2>/dev/null`
  local ssh_port=`uci get gogs.@main[0].ssh_port 2>/dev/null`
  local image_name=`uci get gogs.@main[0].image_name 2>/dev/null`
  local config=`uci get gogs.@main[0].config_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="gogs/gogs:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f gogs

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  if [ -z "$http_port" ]; then 
    http_port=3001
  fi
  if [ -z "$ssh_port" ]; then
    ssh_port=3022
  fi

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/data\" \
    --dns=172.17.0.1 \
    -p $http_port:3000 \
    -p $ssh_port:22 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name gogs \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the gogs"
  echo "      upgrade                Upgrade the gogs"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the gogs"
  echo "      status                 Gogs status"
  echo "      port                   Gogs port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f gogs
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} gogs
  ;;
  "status")
    docker ps --all -f 'name=gogs' --format '{{.State}}'
  ;;
  "port")
    uci -q get gogs.@main[0].http_port 2>/dev/null
  ;;
  *)
    usage
    exit 1
  ;;
esac
