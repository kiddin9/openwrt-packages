#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get drawio.@main[0].port 2>/dev/null`
  local config=`uci get drawio.@main[0].config_path 2>/dev/null`

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
  sed 's/PORT_VAR/'$port'/g' /usr/share/drawio/docker-compose.template.yaml > $config/docker-compose.yaml
  RET=$?
  if [ ! "$RET" = "0" ]; then
    echo "convert docker-compose.yaml failed"
    exit 1
  fi

  cd $config
  export COMPOSE_PROJECT_NAME=linkease-drawio
  docker-compose down || true
  docker-compose up -d
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the drawio"
  echo "      upgrade                Upgrade the drawio"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the drawio"
  echo "      status                 DrawIO status"
  echo "      port                   DrawIO port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f drawio
  ;;
  "start" | "stop" | "restart")
    config=`uci get drawio.@main[0].config_path 2>/dev/null`
    cd $config && docker-compose ${ACTION}
  ;;
  "status")
    docker ps --all -f 'name=linkease-drawio_drawio_1' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=linkease-drawio_drawio_1' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
