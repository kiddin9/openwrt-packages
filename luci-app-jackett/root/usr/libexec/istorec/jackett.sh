#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local save_path=`uci get jackett.@jackett[0].save_path 2>/dev/null`
  local config=`uci get jackett.@jackett[0].config_path 2>/dev/null`
  local port=`uci get jackett.@jackett[0].port 2>/dev/null`
  local auto_update=`uci get jackett.@jackett[0].auto_update 2>/dev/null`
  local IMAGE_NAME=`uci get jackett.@jackett[0].image_name 2>/dev/null`

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi
  if [ -z "$save_path" ]; then
      echo "save path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=9117
  [ -z "$IMAGE_NAME" ] && IMAGE_NAME="linuxserver/jackett:latest"

  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f jackett

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/config\" \
    -v \"$save_path:/downloads\" \
    --dns=172.17.0.1 \
    -p $port:9117 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  if [ -n "$auto_update" ]; then
    if [ "$auto_update" = 1 ]; then
      cmd="$cmd -e AUTO_UPDATE=true"
    else
      cmd="$cmd -e AUTO_UPDATE=false"
    fi
  fi

  cmd="$cmd --name jackett \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

  echo "Waiting 15s to setup"
  sleep 15
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the jackett"
  echo "      upgrade                Upgrade the jackett"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the jackett"
  echo "      status                 Jackett status"
  echo "      port                   Jackett port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f jackett
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} jackett
  ;;
  "status")
    docker ps --all -f 'name=jackett' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=jackett' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
