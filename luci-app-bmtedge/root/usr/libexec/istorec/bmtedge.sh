#!/bin/sh

ACTION=${1}
shift 1

do_install() {
  local path=`uci get bmtedge.@bmtedge[0].cache_path 2>/dev/null`
  local uid=`uci get bmtedge.@bmtedge[0].uid 2>/dev/null`
  local image_name=`uci get bmtedge.@bmtedge[0].image_name 2>/dev/null`

  if [ -z "$path" ]; then
      echo "path is empty!"
      exit 1
  fi

  local netdev=`ip route list|awk ' /^default/ {print $5}'`
  if [ -z "$netdev" ]; then
      echo "defualt gateway is empty!"
      exit 1
  fi

  [ -z "$image_name" ] && image_name="jinshanyun/jinshan-x86_64:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f bmtedge

  local cmd="docker run --restart=unless-stopped -d \
    --privileged \
    --network=host \
    --dns=127.0.0.1 \
    --dns=223.5.5.5 \
    --tmpfs /run \
    --tmpfs /tmp \
    -v \"$path:/data/ksc1\" \
    -v \"$path/containerd:/var/lib/containerd\" \
    -e ksc_datadir=\"/data/ksc1\" \
    -e ksc_net=\"$netdev\" \
    -e ksc_machine_code=\"lsyK17032_$uid\" "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  cmd="$cmd --name bmtedge \"$image_name\""

  echo "$cmd"
  eval "$cmd"

  if [ "$?" = "0" ]; then
    if [ "`uci -q get firewall.bmtedge.enabled`" = 0 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.bmtedge.enabled="1"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  fi

  echo "Install OK!"

}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the bmtedge"
  echo "      upgrade                Upgrade the bmtedge"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the bmtedge"
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
    docker rm -f bmtedge
    if [ "`uci -q get firewall.bmtedge.enabled`" = 1 ]; then
      uci -q batch <<-EOF >/dev/null
        set firewall.bmtedge.enabled="0"
        commit firewall
EOF
      /etc/init.d/firewall reload
    fi
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} bmtedge
  ;;
  "status")
    docker ps --all -f 'name=bmtedge' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=bmtedge' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  *)
    usage
    exit 1
  ;;
esac

