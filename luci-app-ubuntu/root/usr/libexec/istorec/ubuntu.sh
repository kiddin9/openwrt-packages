#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

IMAGE_NAME=''
# linkease/desktop-ubuntu-full-arm64:latest
# linkease/desktop-ubuntu-standard-arm64:latest
# linkease/desktop-ubuntu-full-amd64:latest
# linkease/desktop-ubuntu-standard-amd64:latest

get_image() {
  local version=`uci get ubuntu.@ubuntu[0].version 2>/dev/null`
  
  ARCH="arm64"
  if echo `uname -m` | grep -Eqi 'x86_64'; then
    ARCH='amd64'
  elif  echo `uname -m` | grep -Eqi 'aarch64'; then
    ARCH='arm64'
  else
    ARCH='arm64'
  fi

  IMAGE_NAME=linkease/desktop-ubuntu-${version}-${ARCH}:latest
}

do_install() {
  local http_port=`uci get ubuntu.@ubuntu[0].port 2>/dev/null`
  local password=`uci get ubuntu.@ubuntu[0].password 2>/dev/null`
  [ -z $password ] || password="password"
  [ -z $http_port ] || http_port=6901

  get_image
  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f ubuntu

  local cmd="docker run --restart=unless-stopped -d \
    --dns=172.17.0.1 \
    -u=0:0 \
    --shm-size=512m \
    -p ${http_port}:6901 \
    -e VNC_PW=${password} \
    -e VNC_USE_HTTP=0 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name ubuntu \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the ubuntu"
  echo "      upgrade                Upgrade the ubuntu"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the ubuntu"
  echo "      status                 Ubuntu status"
  echo "      port                   Ubuntu port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f ubuntu
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} ubuntu
  ;;
  "status")
    docker ps --all -f 'name=ubuntu' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=ubuntu' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
