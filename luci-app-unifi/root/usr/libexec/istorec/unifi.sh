#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local hostnet=`uci get unifi.@main[0].hostnet 2>/dev/null`
  local http_port=`uci get unifi.@main[0].http_port 2>/dev/null`
  local image_name=`uci get unifi.@main[0].image_name 2>/dev/null`
  local config=`uci get unifi.@main[0].config_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="lscr.io/linuxserver/unifi-controller:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f unifi

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=8083

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/config\" "

  if [ "$hostnet" = 1 ]; then
    cmd="$cmd\
    --dns=127.0.0.1 \
    --network=host "
  else
    cmd="$cmd\
    --dns=172.17.0.1 \
    -p 3478:3478/udp \
    -p 10001:10001/udp \
    -p 8080:8080 \
    -p $http_port:8443 "
  fi

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name unifi \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the unifi"
  echo "      upgrade                Upgrade the unifi"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the unifi"
  echo "      status                 UnifiController status"
  echo "      port                   UnifiController port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f unifi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} unifi
  ;;
  "status")
    docker ps --all -f 'name=unifi' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=unifi' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->8443/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
