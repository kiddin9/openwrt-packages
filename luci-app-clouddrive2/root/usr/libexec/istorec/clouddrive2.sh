#!/bin/sh
# Author jjm2473@gmail.com

ACTION=${1}
shift 1

IMAGE_NAME='default'

get_image() {
  IMAGE_NAME=`uci -q get clouddrive2.@clouddrive2[0].image 2>/dev/null`
  if [ -z "$IMAGE_NAME" -o "$IMAGE_NAME" == "default" ]; then
    IMAGE_NAME="cloudnas/clouddrive2"
  fi
}

do_install() {
  get_image
  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker stop clouddrive2
  docker rm -f clouddrive2

  do_install_detail
}

do_install_detail() {
  local config=`uci -q get clouddrive2.@clouddrive2[0].config_path 2>/dev/null`
  local cache=`uci -q get clouddrive2.@clouddrive2[0].cache_path 2>/dev/null`
  local port=`uci -q get clouddrive2.@clouddrive2[0].port 2>/dev/null`
  local share_mnt=`uci -q get clouddrive2.@clouddrive2[0].share_mnt 2>/dev/null`

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=19798

  local cmd="docker run --restart=unless-stopped -d -e CLOUDDRIVE_HOME=/Config -v \"$config:/Config\" "
  [ -z "$cache" ] || cmd="$cmd -v \"$cache:/Config/temp\" "

  cmd="$cmd\
    --dns=172.17.0.1 \
    -p $port:19798"

  local tz="`uci -q get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  # make sure shared mount point existed
  /etc/init.d/clouddrive2 boot

  if [ "$share_mnt" = 1 ]; then
    cmd="$cmd -v /mnt:/mnt"
    mountpoint -q /mnt && cmd="$cmd:rslave"
  fi
  cmd="$cmd -v /mnt/CloudNAS:/mnt/CloudNAS:shared"

  # fuse
  cmd="$cmd\
    --cap-add SYS_ADMIN \
    --security-opt apparmor:unconfined \
    --device /dev/fuse:/dev/fuse"

  cmd="$cmd --name clouddrive2 \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the CloudDrive2"
  echo "      upgrade                Upgrade the CloudDrive2"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the CloudDrive2"
  echo "      status                 CloudDrive2 status"
  echo "      port                   CloudDrive2 port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker stop clouddrive2
    docker rm -f clouddrive2
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} clouddrive2
  ;;
  "status")
    docker ps --all -f 'name=clouddrive2' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=clouddrive2' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->19798/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
