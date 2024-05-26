#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get ittools.@main[0].port 2>/dev/null`
  local image_name=`uci get ittools.@main[0].image_name 2>/dev/null`

  [ -z "$image_name" ] && image_name="linuxserver/ittools:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f ittools

  [ -z "$port" ] && port=9070

  local cmd="docker run --restart=unless-stopped -d -h ITToolsServer "

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:80 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name ittools \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the ittools"
  echo "      upgrade                Upgrade the ittools"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the ittools"
  echo "      status                 ITTools status"
  echo "      port                   ITTools port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f ittools
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} ittools
  ;;
  "status")
    docker ps --all -f 'name=ittools' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=ittools' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->9070/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
