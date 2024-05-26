#!/bin/sh

ACTION=${1}
shift 1

get_image() {
  IMAGE_NAME="jxxghp/nas-tools"
}

do_install() {
  local config=`uci get nastools.@nastools[0].config_path 2>/dev/null`
  local port=`uci get nastools.@nastools[0].http_port 2>/dev/null`
  local auto_update=`uci get nastools.@nastools[0].auto_upgrade 2>/dev/null`
  local image_name=`uci get nastools.@nastools[0].image_name 2>/dev/null`

  [ -z "$image_name" ] && image_name="sungamma/nas-tools:2.9.1"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f nastools

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=3003

  local cmd="docker run --restart=unless-stopped -d \
    --hostname nastools \
    -v \"$config:/config\" \
    --dns=172.17.0.1 \
    -p $port:3000 \
    -e UMASK=000"

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  if [ -n "$auto_update" ]; then
    if [ "$auto_update" = 1 ]; then
      cmd="$cmd -e NASTOOL_AUTO_UPDATE=true"
    else
      cmd="$cmd -e NASTOOL_AUTO_UPDATE=false"
    fi
  fi

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"

  cmd="$cmd --name nastools \"$image_name\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the nastools"
  echo "      upgrade                Upgrade the nastools"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the nastools"
  echo "      status                 NasTools status"
  echo "      port                   NasTools port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f nastools
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} nastools
  ;;
  "status")
    docker ps --all -f 'name=nastools' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=nastools' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
