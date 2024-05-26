#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local config=`uci get penpot.@main[0].config_path 2>/dev/null`
  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi
  mkdir -p $config

  lua /usr/libexec/istorec/penpot_template.lua penpot /usr/share/penpot/config.template.env $config/config.env
  RET=$?
  if [ ! "$RET" = "0" ]; then
    echo "convert config.env failed"
    exit 1
  fi

  lua /usr/libexec/istorec/penpot_template.lua penpot /usr/share/penpot/docker-compose.template.yaml $config/docker-compose.yaml
  RET=$?
  if [ ! "$RET" = "0" ]; then
    echo "convert config.env failed"
    exit 1
  fi

  cd $config
  docker-compose down || true
  docker-compose up -d
  echo "Wait 120 to intialize"
  sleep 120
  echo "Now you should create a user manually"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the penpot"
  echo "      upgrade                Upgrade the penpot"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the penpot"
  echo "      status                 Penpot status"
  echo "      port                   Penpot port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    config=`uci get penpot.@main[0].config_path 2>/dev/null`
    cd $config && docker-compose down
  ;;
  "start" | "stop" | "restart")
    config=`uci get penpot.@main[0].config_path 2>/dev/null`
    cd $config && docker-compose ${ACTION}
  ;;
  "status")
    docker ps --all -f 'name=penpot_penpot-frontend_1' --format '{{.State}}'
  ;;
  "port")
    uci get -q penpot.@main[0].http_port 2>/dev/null
  ;;
  "create-user")
    echo docker exec -ti penpot_penpot-backend_1 ./manage.sh create-profile -u "${1}" -p "${2}" -n "${3}"
    docker exec -ti penpot_penpot-backend_1 ./manage.sh create-profile -u "${1}" -p "${2}" -n "${3}"
  ;;
  *)
    usage
    exit 1
  ;;
esac
