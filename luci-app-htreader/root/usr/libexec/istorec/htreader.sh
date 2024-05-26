#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local port=`uci get htreader.@main[0].port 2>/dev/null`
  local multiuser=`uci get htreader.@main[0].multiuser 2>/dev/null`
  local active_code=`uci get htreader.@main[0].active_code 2>/dev/null`
  local password=`uci get htreader.@main[0].password 2>/dev/null`
  local image_name=`uci get htreader.@main[0].image_name 2>/dev/null`
  local config=`uci get htreader.@main[0].config_path 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi

  [ -z "$image_name" ] && image_name="hectorqin/reader"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f htreader

  [ -z "$port" ] && port=9060

  mkdir -p $config/storage
  mkdir -p $config/logs
  local cmd="docker run --restart=unless-stopped -d -h HTReaderServer \
    -e \"SPRING_PROFILES_ACTIVE=prod\" \
    -v \"$config/logs:/logs\" \
    -v \"$config/storage:/storage\" "

  if [ "$multiuser" = "1" ]; then
    cmd="$cmd -e \"READER_APP_SECUREKEY=$password\" -e \"READER_APP_INVITECODE=$active_code\" "
  fi

  cmd="$cmd\
  --dns=172.17.0.1 \
  -p $port:8080 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name htreader \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the htreader"
  echo "      upgrade                Upgrade the htreader"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the htreader"
  echo "      status                 HTReader status"
  echo "      port                   HTReader port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f htreader
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} htreader
  ;;
  "status")
    docker ps --all -f 'name=htreader' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=htreader' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->9060/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
