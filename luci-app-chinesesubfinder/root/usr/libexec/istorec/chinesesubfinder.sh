#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get chinesesubfinder.@main[0].http_port 2>/dev/null`
  local web_port=`uci get chinesesubfinder.@main[0].web_port 2>/dev/null`
  local image_name=`uci get chinesesubfinder.@main[0].image_name 2>/dev/null`
  local config=`uci get chinesesubfinder.@main[0].config_path 2>/dev/null`
  local media=`uci get chinesesubfinder.@main[0].media_path 2>/dev/null`

  [ -z "$image_name" ] && image_name="allanpk716/chinesesubfinder:latest-lite"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f chinesesubfinder

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=19035
  [ -z "$web_port" ] && web_port=19037

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/config\" --dns=172.17.0.1 -p $http_port:19035 -p $web_port:19037 \
     --hostname chinesesubfinder \
     --log-driver \"json-file\" \
     --log-opt \"max-size=100m\" "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  [ -z "$media" ] || cmd="$cmd -v \"$media:/media\""

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name chinesesubfinder \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the chinesesubfinder"
  echo "      upgrade                Upgrade the chinesesubfinder"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the chinesesubfinder"
  echo "      status                 ChineseSubFinder status"
  echo "      port                   ChineseSubFinder port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f chinesesubfinder
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} chinesesubfinder
  ;;
  "status")
    docker ps --all -f 'name=chinesesubfinder' --format '{{.State}}'
  ;;
  "port")
    uci -q get chinesesubfinder.@main[0].http_port 2>/dev/null
  ;;
  *)
    usage
    exit 1
  ;;
esac
