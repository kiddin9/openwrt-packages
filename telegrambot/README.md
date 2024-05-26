# Openwrt Telegram Bot

Telegram bot for router with firmware Lede/Openwrt.

## Implemented functions (Commands via Telegram message)

  - */memory* return RAM info
  - */clients* connected clients
  - */wll_list* wifi clients
  - */wifi_list* wifi info
  - */reboot* reboot the device
  - */wol <mac_address>* wake on lan over the Internet
  - */wanip* WAN ip address
  - */<script_name>* any scripts in the `plugins` directory

## Prerequisites

Telegram bot run under Lede or Openwrt firmware than the first prerequisite is to have Lede/Openwrt installed.

Second prerequisite is to have `curl` package installed. You can do this with command `opkg update && opkg install curl`.

## Installation Steps

### Step one:

- Get your chat_id of Telegram. If you don't know what is your chat_id you can use bot @get_id_bot.

- Get a bot token and start your bot. If you don't know how get it you can use bot @BotFather. Send him /newbot command , name of your new bot and a username. Get the returned string "Use this token to access the HTTP API:" 

### Step two:

Install Package  [telegrambot_0.0.3-1_all.ipk](http://openwrt.132lan.ru/packages/packages-19.07/mipsel_24kc/packages/telegrambot_0.0.3-1_all.ipk) of your Lede/Openwrt system.

### Step three:

Set your variables (bot token and chat id) in `telegrambot` file under `/etc/config/` dir.

```sh
uci set telegrambot.config.bot_token='[PUT YOUR BOT TOKEN HERE]'
uci set telegrambot.config.chat_id='[PUT YOUR CHAT ID HERE]'

uci commit telegrambot
```

Start `telegrambot` service with commands:

```/etc/init.d/telegrambot restart```

Enjoy your bot!
