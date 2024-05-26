#!/bin/sh
# Author jjm2473@gmail.com
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

ARCH="default"
IMAGE_NAME='default'

get_image() {
  if grep -Eq ',rtd-?129.$' /proc/device-tree/compatible 2>/dev/null; then
    ARCH="rtd129x"
  elif grep -q 'rockchip,' /proc/device-tree/compatible 2>/dev/null; then
    ARCH="rockchip"
  fi
  IMAGE_NAME=`uci get jellyfin.@jellyfin[0].image 2>/dev/null`
  if [ -z "$IMAGE_NAME" -o "$IMAGE_NAME" == "default" ]; then
    if [ "${ARCH}" = "rtd129x" ]; then
      IMAGE_NAME="jjm2473/jellyfin-rtk:latest"
      if uname -r | grep -q '^4\.9\.'; then
        IMAGE_NAME="jjm2473/jellyfin-rtk:4.9-latest"
      fi
    elif [ "${ARCH}" = "rockchip" ]; then
      IMAGE_NAME="jjm2473/jellyfin-mpp:latest"
    else
      IMAGE_NAME="jellyfin/jellyfin"
    fi
  fi
}

do_install() {
  get_image
  echo "docker pull ${IMAGE_NAME}"
  docker pull ${IMAGE_NAME}
  docker rm -f jellyfin

  do_install_detail
}

do_install_detail() {
  local hostnet=`uci get jellyfin.@jellyfin[0].hostnet 2>/dev/null`
  local media=`uci get jellyfin.@jellyfin[0].media_path 2>/dev/null`
  local config=`uci get jellyfin.@jellyfin[0].config_path 2>/dev/null`
  local cache=`uci get jellyfin.@jellyfin[0].cache_path 2>/dev/null`
  local port=`uci get jellyfin.@jellyfin[0].port 2>/dev/null`
  local dev

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$port" ] && port=8096

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/config\" "
  if [ "${ARCH}" = "rtd129x" ]; then
    cmd="$cmd\
    --device /dev/rpc0:/dev/rpc0 \
    --device /dev/rpc1:/dev/rpc1 \
    --device /dev/rpc2:/dev/rpc2 \
    --device /dev/rpc3:/dev/rpc3 \
    --device /dev/rpc4:/dev/rpc4 \
    --device /dev/rpc5:/dev/rpc5 \
    --device /dev/rpc6:/dev/rpc6 \
    --device /dev/rpc7:/dev/rpc7 \
    --device /dev/rpc100:/dev/rpc100 \
    --device /dev/uio250:/dev/uio250 \
    --device /dev/uio251:/dev/uio251 \
    --device /dev/uio252:/dev/uio252 \
    --device /dev/uio253:/dev/uio253 \
    --device /dev/ion:/dev/ion \
    --device /dev/ve3:/dev/ve3 \
    --device /dev/vpu:/dev/vpu \
    --device /dev/memalloc:/dev/memalloc \
    -v /tmp/shm:/dev/shm \
    -v /sys/class/uio:/sys/class/uio \
    -v /var/tmp/vowb:/var/tmp/vowb \
    --pid=host "
  elif [ "${ARCH}" = "rockchip" -a -e "/dev/rga" ]; then
    cmd="$cmd\
    -t \
    --privileged "
    for dev in iep rga dri dma_heap mpp_service mpp-service vpu_service vpu-service \
        hevc_service hevc-service rkvdec rkvenc avsd vepu h265e ; do
      [ -e "/dev/$dev" ] && cmd="$cmd --device /dev/$dev"
    done
  elif [ -d /dev/dri ]; then
    cmd="$cmd\
    -v /dev/dri:/dev/dri \
    --privileged "
  fi
  if [ "$hostnet" = 1 ]; then
    cmd="$cmd\
    --dns=127.0.0.1 \
    --network=host "
  else
    cmd="$cmd\
    --dns=172.17.0.1 \
    -p $port:8096 "
  fi

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  [ -z "$cache" ] || cmd="$cmd -v \"$cache:/config/transcodes\""
  [ -z "$media" ] || cmd="$cmd -v \"$media:/media\""

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name jellyfin \"$IMAGE_NAME\""

  echo "$cmd"
  eval "$cmd"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the jellyfin"
  echo "      upgrade                Upgrade the jellyfin"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the jellyfin"
  echo "      status                 Jellyfin status"
  echo "      port                   Jellyfin port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f jellyfin
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} jellyfin
  ;;
  "status")
    docker ps --all -f 'name=jellyfin' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=jellyfin' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*->8096/tcp' | sed 's/0.0.0.0:\([0-9]*\)->.*/\1/'
  ;;
  *)
    usage
    exit 1
  ;;
esac
