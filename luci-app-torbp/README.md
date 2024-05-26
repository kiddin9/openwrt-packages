### Описание

OpenWrt LuCI модуль для Tor с SOCKS 5 proxy сервером и возможностью работы с мостами. Без функции выходного узла, только SOCKS 5 proxy.

<p align="center">
 <img src="https://raw.githubusercontent.com/zerolabnet/luci-app-torbp/main/docs/01-scr.png" width="100%">
</p>

### Установка зависимостей

```bash
opkg install wget-ssl tor tor-geoip obfs4proxy
```

### Установка luci-app-torbp

```bash
cd /tmp
wget https://github.com/zerolabnet/luci-app-torbp/releases/download/1.0/luci-app-torbp_1.0-1_all.ipk
opkg install luci-app-torbp_1.0-1_all.ipk
rm *.ipk
```

### Порты по умолчанию

```
9150 - порт SOCKS 5 proxy для трафика через сеть Tor
```

### Можем использовать в OpenClash:

```yaml
  - name: "Tor"
    type: socks5
    server: ROUTER_IP
    port: 9150
```
