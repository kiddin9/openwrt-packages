#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local hostnet=`uci get emby.@main[0].hostnet 2>/dev/null`
  local http_port=`uci get emby.@main[0].http_port 2>/dev/null`
  local image_name=`uci get emby.@main[0].image_name 2>/dev/null`
  local config=`uci get emby.@main[0].config_path 2>/dev/null`
  local media=`uci get emby.@main[0].media_path 2>/dev/null`
  local cache=`uci get emby.@main[0].cache_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="emby/embyserver"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f emby

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  # not conflict with jellyfin
  [ -z "$http_port" ] && http_port=8097

  local cmd="docker run --restart=unless-stopped -d -u 0 -e UID=0 -e GID=0 -e GIDLIST=0 -v \"$config:/config\" "

  if [ -d /dev/dri ]; then
    cmd="$cmd\
    --device /dev/dri:/dev/dri \
    --privileged "
  fi

  if [ "$hostnet" = 1 ]; then
    cmd="$cmd\
    --dns=127.0.0.1 \
    --network=host "
  else
    cmd="$cmd\
    --dns=172.17.0.1 \
    -p $http_port:8096 "
  fi

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  [ -z "$cache" ] || cmd="$cmd -v \"$cache:/config/cache\""
  [ -z "$media" ] || cmd="$cmd -v \"$media:/data\""

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name emby \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the emby"
  echo "      upgrade                Upgrade the emby"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the emby"
  echo "      status                 Emby status"
  echo "      port                   Emby port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f emby
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} emby
  ;;
  "status")
    docker ps --all -f 'name=emby' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=emby' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->8096/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
