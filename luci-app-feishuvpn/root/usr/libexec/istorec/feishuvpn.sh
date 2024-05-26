#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local image_name=`uci get feishuvpn.@main[0].image_name 2>/dev/null`
  local config=`uci get feishuvpn.@main[0].config_path 2>/dev/null`

  if [ -z "$config" ]; then
    echo "config path is empty!"
    exit 1
  fi

  [ -z "$image_name" ] && image_name="registry.cn-qingdao.aliyuncs.com/feishuwg/p2p:v2.2"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f feishuvpn

  local cmd="docker run --restart=unless-stopped -d -h FeiShuVpnServer -v \"$config:/data/conf\" "

  cmd="$cmd\
  --cap-add=ALL \
  --privileged=true \
  --device=/dev/net/tun \
  --dns=127.0.0.1 \
  --network=host "

 # local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
 # [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name feishuvpn \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the feishuvpn"
  echo "      upgrade                Upgrade the feishuvpn"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the feishuvpn"
  echo "      status                 FeiShuVpn status"
  echo "      port                   FeiShuVpn port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f feishuvpn
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} feishuvpn
  ;;
  "status")
    docker ps --all -f 'name=feishuvpn' --format '{{.State}}'
  ;;
  "port")
    echo 9091
  ;;
  *)
    usage
    exit 1
  ;;
esac
