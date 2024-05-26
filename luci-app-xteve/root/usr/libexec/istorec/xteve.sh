#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get xteve.@main[0].port 2>/dev/null`
  local image_name=`uci get xteve.@main[0].image_name 2>/dev/null`
  local config=`uci get xteve.@main[0].config_path 2>/dev/null`
  local tz=`uci get xteve.@main[0].time_zone 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi
  if [ -z "$image_name" ]; then
    local arch=`uname -m`
    [ "$arch" = "x86_64" -o "$arch" = "aarch64" ] && image_name="jjm2473/xteve_guide2go"
    if [ -z "$image_name" ]; then
      echo "$arch is unsupported!" >&2
      exit 1
    fi
  fi

  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f xteve

  [ -z "$port" ] && port=34400

  local cmd="docker run --restart=unless-stopped -d \
    -v $config:/root/.xteve:rw \
    -v $config/_config:/config:rw \
    -v $config/_guide2go:/guide2go:rw \
    -v /tmp/xteve:/tmp/xteve:rw \
    -p $port:34400 "

  if [ -z "$tz" ]; then
    tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  fi
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name xteve \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the xteve"
  echo "      upgrade                Upgrade the xteve"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the xteve"
  echo "      status                 Xteve status"
  echo "      port                   Xteve port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f xteve
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} xteve
  ;;
  "status")
    docker ps --all -f 'name=xteve' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=xteve' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
