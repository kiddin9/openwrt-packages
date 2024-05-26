#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

do_install() {
  local http_port=`uci get codeserver.@main[0].http_port 2>/dev/null`
  local image_name=`uci get codeserver.@main[0].image_name 2>/dev/null`
  local config=`uci get codeserver.@main[0].config_path 2>/dev/null`
  local env_password=`uci get codeserver.@main[0].env_password 2>/dev/null`
  local env_hashed_password=`uci get codeserver.@main[0].env_hashed_password 2>/dev/null`
  local env_sudo_password=`uci get codeserver.@main[0].env_sudo_password 2>/dev/null`
  local env_sudo_password_hash=`uci get codeserver.@main[0].env_sudo_password_hash 2>/dev/null`
  local env_proxy_domain=`uci get codeserver.@main[0].env_proxy_domain 2>/dev/null`

  [ -z "$image_name" ] && image_name="lscr.io/linuxserver/code-server:latest"
  echo "docker pull ${image_name}"
  docker pull ${image_name}
  docker rm -f codeserver

  if [ -z "$config" ]; then
      echo "config path is empty!"
      exit 1
  fi

  [ -z "$http_port" ] && http_port=8085

  local cmd="docker run --restart=unless-stopped -d -v \"$config:/config\" \
    --dns=172.17.0.1 \
    -e DEFAULT_WORKSPACE=/config/workspace \
    -p $http_port:8443 "

  local tz="`uci get system.@system[0].zonename | sed 's/ /_/g'`"
  [ -z "$tz" ] || cmd="$cmd -e TZ=$tz"

  [ -z "$env_password" ] || cmd="$cmd -e \"PASSWORD=$env_password\""
  [ -z "$env_hashed_password" ] || cmd="$cmd -e \"HASHED_PASSWORD=$env_hashed_password\""
  [ -z "$env_sudo_password" ] || cmd="$cmd -e \"SUDO_PASSWORD=$env_sudo_password\""
  [ -z "$env_sudo_password_hash" ] || cmd="$cmd -e \"SUDO_PASSWORD_HASH=$env_sudo_password_hash\""
  [ -z "$env_proxy_domain" ] || cmd="$cmd -e \"PROXY_DOMAIN=$env_proxy_domain\""

  cmd="$cmd -v /mnt:/mnt"
  mountpoint -q /mnt && cmd="$cmd:rslave"
  cmd="$cmd --name codeserver \"$image_name\""

  echo "$cmd"
  eval "$cmd"
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      install                Install the codeserver"
  echo "      upgrade                Upgrade the codeserver"
  echo "      rm/start/stop/restart  Remove/Start/Stop/Restart the codeserver"
  echo "      status                 CodeServer status"
  echo "      port                   CodeServer port"
}

case ${ACTION} in
  "install")
    do_install
  ;;
  "upgrade")
    do_install
  ;;
  "rm")
    docker rm -f codeserver
  ;;
  "start" | "stop" | "restart")
    docker ${ACTION} codeserver
  ;;
  "status")
    docker ps --all -f 'name=codeserver' --format '{{.State}}'
  ;;
  "port")
    docker ps --all -f 'name=codeserver' --format '{{.Ports}}' | grep -om1 '0.0.0.0:[0-9]*' | sed 's/0.0.0.0://'
  ;;
  "git-config")
    docker exec codeserver git config --global user.name "${1}"
    docker exec codeserver git config --global user.email "${2}"
    echo "git config --global user.name ${1}"
    echo "git config --global user.email ${2}"
  ;;
  *)
    usage
    exit 1
  ;;
esac
