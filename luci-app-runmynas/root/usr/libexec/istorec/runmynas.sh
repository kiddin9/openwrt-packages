#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

command_exists() { 
  command -v "$@" >/dev/null 2>&1
}

Download_Files(){
  local URL=$1
  local FileName=$2
  if command_exists curl; then
    curl -sSLk ${URL} -o ${FileName}
  elif command_exists wget; then
    wget -c --no-check-certificate ${URL} -O ${FileName}
  fi
  if [ $? -eq 0 ]; then
    echo "Download OK"
  else
    echo "Download failed"
    exit 1
  fi
}

do_build() {
  local download=`uci get runmynas.@runmynas[0].download 2>/dev/null`
  local target=`uci get runmynas.@runmynas[0].target 2>/dev/null`
  local path=`uci get runmynas.@runmynas[0].path 2>/dev/null`
  [ ! -z $download ] || download="github"
  [ ! -z $target ] || target="x86_64"

  if echo `uname -m` | grep -Eqi 'x86_64'; then
    echo "Support x86_64"
  else
    echo "Not x86_64, only support x86_64, exit"
    exit 1
  fi

  if [ -z "$path" ]; then
    echo "path is empty"
    exit 3
  fi

  mkdir -p $path
  if [ ! -f "${path}/runmynas.sh" ]; then
    if [ "$download" = "github" ]; then
      DLURL=`curl -s https://api.github.com/repos/linkease/iStoreNAS/releases/latest | grep tarball_url | cut -d '"' -f 4`
    else
      DLURL="https://fw0.koolcenter.com/iStoreNAS/runmynas/runmynas.tar.gz"
    fi
    echo "download $DLURL"
    rm -f /tmp/rumynas-source.tar.gz
    Download_Files ${DLURL} /tmp/rumynas-source.tar.gz
    tar -C ${path} --strip-components=1 -zxf /tmp/rumynas-source.tar.gz
    if [ ! -f "${path}/runmynas.sh" ]; then
      echo "runmynas.sh not found, failed!"
      exit 2
    fi
    rm -f /tmp/rumynas-source.tar.gz
  fi

  cd ${path}
  echo "./runmynas.sh $target"
  ./runmynas.sh $target
}

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      build                 Build your NAS"
}

case ${ACTION} in
  "build")
    do_build
  ;;
  *)
    usage
    exit 1
  ;;
esac

