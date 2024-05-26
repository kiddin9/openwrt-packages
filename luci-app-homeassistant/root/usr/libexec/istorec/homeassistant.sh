#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local config=`uci get homeassistant.@homeassistant[0].config_path 2>/dev/null`
  local IMAGE_NAME=`uci get homeassistant.@homeassistant[0].image_name 2>/dev/null`
  local tz=`uci get homeassistant.@homeassistant[0].time_zone 2>/dev/null`

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f homeassistant

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/config\" \
    --privileged \
    --network=host \
    --dns=127.0.0.1 "

  if [ -z "$tz" ]; then
    tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  fi
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name homeassistant \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

  RET=$?
  if [ "$RET" = "0" ]; then
    echo "Wait 10 seconds for homeassistant boot..."
    sleep 10
    do_hacs_install
  fi
}

do_hacs_install() {
  echo "Install HACS"
  echo "rm -f custom_components/hacs.zip config/custom_components/hacs.zip ; wget -O - https://get.hacs.xyz | bash -" | docker exec -i homeassistant bash -
  sleep 3
  echo "restart homeassistant"
  docker restart homeassistant
  return 0
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the homeassistant"
  echo "      upgrade                Upgrade the homeassistant"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the homeassistant"
  echo "      status                 Home Assistant status"
  echo "      port                   Home Assistant port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f homeassistant
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} homeassistant
  ;;
  "status")
    docker ps --all -f 'name=homeassistant' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=homeassistant' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  "hacs-install")
    do_hacs_install
  ;;
  *)
    usage
    exit 1
  ;;
esac
