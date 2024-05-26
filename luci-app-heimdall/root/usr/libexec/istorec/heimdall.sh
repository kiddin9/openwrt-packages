#!/bin/sh

ACTION=${1}
shift 1

get_image() {
  IMAGE_NAME="lscr.io/linuxserver/heimdall:latest"
}

do_install() {
  get_image
  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f heimdall

  do_install_detail
}

do_install_detail() {
  local config=`uci get heimdall.@heimdall[0].config_path 2>/dev/null`
  local http_port=`uci get heimdall.@heimdall[0].http_port 2>/dev/null`
  local https_port=`uci get heimdall.@heimdall[0].https_port 2>/dev/null`

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=8088
  [ -z "$https_port" ] && http_port=8089

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/config\" \
    --dns=172.17.0.1 \
    -p $http_port:80 \
    -p $https_port:443 "

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name heimdall \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the heimdall"
  echo "      upgrade                Upgrade the heimdall"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the heimdall"
  echo "      status                 Heimdall status"
  echo "      port                   Heimdall http port"
  echo "      https_port             Heimdall https port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f heimdall
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} heimdall
  ;;
  "status")
    docker ps --all -f 'name=heimdall' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=heimdall' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->80/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  "https_port")
    docker ps --all -f 'name=heimdall' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->443/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
