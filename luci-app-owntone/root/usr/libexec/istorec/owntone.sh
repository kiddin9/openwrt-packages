#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local image_name=`uci get owntone.@main[0].image_name 2>/dev/null`
  local config=`uci get owntone.@main[0].config_path 2>/dev/null`
  local media=`uci get owntone.@main[0].music_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="lscr.io/linuxserver/daapd:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f owntone

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  local cmd="docker run --restart=unless-stopped -d \
    -v \"$config:/config\" \
    -v \"$media:/music\" \
    --dns=127.0.0.1 \
    --network=host "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name owntone \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the owntone"
  echo "      upgrade                Upgrade the owntone"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the owntone"
  echo "      status                 Owntone status"
  echo "      port                   Owntone port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f owntone
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} owntone
  ;;
  "status")
    docker ps --all -f 'name=owntone' --format '{{.State}}'
  ;;
  "port")
    echo 3689
  ;;
  *)
    usage
    exit 1
  ;;
esac
