#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get photoprism.@main[0].http_port 2>/dev/null`
  local image_name=`uci get photoprism.@main[0].image_name 2>/dev/null`
  local config=`uci get photoprism.@main[0].config_path 2>/dev/null`
  local picture=`uci get photoprism.@main[0].picture_path 2>/dev/null`
  local password=`uci get photoprism.@main[0].password 2>/dev/null`

  [ -z "$image_name" ] && image_name="photoprism/photoprism:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f photoprism

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=2342

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/photoprism/storage\" --dns=172.17.0.1 -p $http_port:2342 \
    -e PHOTOPRISM_UPLOAD_NSFW=\"true\" \
    -e PHOTOPRISM_ADMIN_PASSWORD=\"$password\" "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  [ -z "$picture" ] || cmd="$cmd -v \"$picture:/photoprism/originals\""

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name photoprism \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the photoprism"
  echo "      upgrade                Upgrade the photoprism"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the photoprism"
  echo "      status                 PhotoPrism status"
  echo "      port                   PhotoPrism port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f photoprism
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} photoprism
  ;;
  "status")
    docker ps --all -f 'name=photoprism' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=photoprism' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->2342/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
