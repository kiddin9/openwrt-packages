#!/bin/sh
# Author Xiaobao(xiaobao@linkease.com)

ACTION=${1}
shift 1

usage() {
  echo "usage: $0 sub-command"
  echo "where sub-command is one of:"
  echo "      turn_off_ipv6                   Disable IPv6"
  echo "      full_ipv6                       Full IPv6"
  echo "      half_ipv6                       Half IPv6 (Only Router)"
  echo "      reset_rom_pkgs                  Reset pkgs from rom"
  echo "      qb_reset_password               Reset qBitorent password"
  echo "      disk_power_mode                 Show disk power status"
  echo "      speedtest                       Start a speedtest"
}

case ${ACTION} in
  "turn_off_ipv6"|\
  "full_ipv6"|\
  "half_ipv6")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "reset_rom_pkgs")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "qb_reset_password")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "disk_power_mode")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "speedtest")
    /usr/share/systools/speedtest.run ${1}
  ;;
  "openssl-aes256gcm")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "openssl-chacha20-poly1305")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "istore-reinstall")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  "disable-wandrop")
    bash "/usr/share/systools/${ACTION}.run"
  ;;
  *)
    usage
    exit 1
  ;;
esac

