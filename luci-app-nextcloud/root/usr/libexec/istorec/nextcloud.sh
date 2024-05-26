#!/bin/sh

ACTION=${1}
shift 1

get_image() {
  IMAGE_NAME="nextcloud"
}

do_install() {
  get_image

  do_install_detail
}

do_install() {
  local config=`uci get nextcloud.@nextcloud[0].config_path 2>/dev/null`
  local port=`uci get nextcloud.@nextcloud[0].port 2>/dev/null`
  local IMAGE_NAME=`uci get nextcloud.@nextcloud[0].image_name 2>/dev/null`

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=8082
  [ -z "$IMAGE_NAME" ] && IMAGE_NAME=nextcloud

  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f nextcloud

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/var/www/html\" \
    --dns=172.17.0.1 \
    -p $port:80 "

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name nextcloud \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the nextcloud"
  echo "      upgrade                Upgrade the nextcloud"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the nextcloud"
  echo "      status                 Nextcloud status"
  echo "      port                   Nextcloud port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f nextcloud
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} nextcloud
  ;;
  "status")
    docker ps --all -f 'name=nextcloud' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=nextcloud' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
