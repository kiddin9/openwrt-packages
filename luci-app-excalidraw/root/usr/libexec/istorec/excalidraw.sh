#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get excalidraw.@main[0].port 2>/dev/null`
  local config=`uci get excalidraw.@main[0].config_path 2>/dev/null`
  local image_ver=`uci get excalidraw.@main[0].image_ver 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi

  mkdir -p $config
  RET=$?
  if [ ! "$RET" = "0" ]; then
    echo "mkdir config path failed"
    exit 1
  fi

  [ -z $port ] && port=8090
  sed 's/PORT_VAR/'$port'/g; s/IMAGE_VER_VAR/'$image_ver'/g' /usr/share/excalidraw/docker-compose.template.yaml > $config/docker-compose.yaml
  RET=$?
  if [ ! "$RET" = "0" ]; then
    echo "convert docker-compose.yaml failed"
    exit 1
  fi

  cd $config
  export COMPOSE_PROJECT_NAME=linkease-excalidraw
  docker-compose down || true
  docker-compose up -d
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the excalidraw"
  echo "      upgrade                Upgrade the excalidraw"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the excalidraw"
  echo "      status                 Excalidraw status"
  echo "      port                   Excalidraw port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f excalidraw
  ;;
  "start" | "stop" | "restart")
    config=`uci get excalidraw.@main[0].config_path 2>/dev/null`
    cd $config && docker-compose ${ACTION}
  ;;
  "status")
    docker ps --all -f 'name=linkease-excalidraw_frontend_1' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=linkease-excalidraw_frontend_1' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
