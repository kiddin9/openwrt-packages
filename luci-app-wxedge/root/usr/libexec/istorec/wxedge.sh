#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local path=`uci get wxedge.@wxedge[0].cache_path 2>/dev/null`
  local image_name=`uci get wxedge.@wxedge[0].image_name 2>/dev/null`

  if [ -z "$path" ]; then
      echo "path is empty!"
      exit 1
  fi

  [ -z "$image_name" ] && image_name="onething1/wxedge"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f wxedge

  local cmd="docker run --restart=unless-stopped -d \
    --privileged \
    --network=host \
    --dns=127.0.0.1 \
    --tmpfs /run \
    --tmpfs /tmp \
    -v \"$path:/storage\" \
    -v \"$path/containerd:/var/lib/containerd\" \
    -e PLACE=CTKS"

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name wxedge \"$image_name\""

  echo "$cmd"
  eval "$cmd"

  if [ "$?" = "0" ]; then
    if [ "`uci -q get firewall.wxedge.enabled`" = 0 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.wxedge.enabled="1"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  fi

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the wxedge"
  echo "      upgrade                Upgrade the wxedge"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the wxedge"
  echo "      status                 Onething Edge status"
  echo "      port                   Onething Edge port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f wxedge
    if [ "`uci -q get firewall.wxedge.enabled`" = 1 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.wxedge.enabled="0"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} wxedge
  ;;
  "status")
    docker ps --all -f 'name=wxedge' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=wxedge' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac
