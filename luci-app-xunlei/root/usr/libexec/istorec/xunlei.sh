#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local hostnet=`uci get xunlei.@main[0].hostnet 2>/dev/null`
  local port=`uci get xunlei.@main[0].port 2>/dev/null`
  local image_name=`uci get xunlei.@main[0].image_name 2>/dev/null`
  local config=`uci get xunlei.@main[0].config_path 2>/dev/null`
  local dl=`uci get xunlei.@main[0].dl_path 2>/dev/null`
  local hostname=`uci get system.@system[0].hostname 2>/dev/null`

  [ -z "$image_name" ] && image_name="registry.cn-shenzhen.aliyuncs.com/cnk3x/xunlei:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f xunlei

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=2345

  local cmd="docker run --restart=unless-stopped -d -h $hostname \
    -v \"$config:/xunlei/data\" \
    -v \"$dl:/xunlei/downloads\" --privileged "

  if [ "$hostnet" = 1 ]; then
    cmd="$cmd\
    --dns=127.0.0.1 \
    --network=host "
  else
    cmd="$cmd\
    --dns=172.17.0.1 \
    -p $port:2345 "
  fi

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name xunlei \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the xunlei"
  echo "      upgrade                Upgrade the xunlei"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the xunlei"
  echo "      status                 Xunlei status"
  echo "      port                   Xunlei port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f xunlei
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} xunlei
  ;;
  "status")
    docker ps --all -f 'name=xunlei' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=xunlei' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->2345/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
