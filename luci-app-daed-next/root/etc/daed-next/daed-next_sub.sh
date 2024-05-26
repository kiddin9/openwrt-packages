#!/bin/sh

USERNAME=$(uci -q get daed-next.config.daed_username)
PASSWORD=$(uci -q get daed-next.config.daed_password)
PORT=2023
GRAPHQL_URL="http://127.0.0.1:"$PORT"/graphql"
CRON_FILE="/etc/crontabs/root"
RANDOM_SEED=$RANDOM
RANDOM_NUM=$((RANDOM_SEED % 10 + 1))

login() {
	LOGIN=$(curl -s -X POST -H "Content-Type: application/json" -d '{"query":"query Token($username: String!, $password: String!) {\n token(username: $username, password: $password)\n}","variables":{"username":"'"$USERNAME"'","password":"'"$PASSWORD"'"}}' $GRAPHQL_URL)
	JSON=${LOGIN#\"}
	JSON=${LOGIN%\"}
	TOKEN=$(echo $JSON | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
}

update_subscription() {
	SUBSCRIPTION_ID_LIST=$(curl -s -X POST -H "Authorization: $TOKEN" -d '{"query": "query Subscriptions {\n subscriptions {\nid\ntag\nstatus\nlink\ninfo\nupdatedAt\nnodes {\nedges {\nid\nname\nprotocol\nlink\n}\n}\n}\n}", "operationName": "Subscriptions"}' $GRAPHQL_URL | grep -o '"id":"[^"]*","tag"' | grep -o 'id":"[^"]*' | grep -o '[^"]*$')
	echo "$SUBSCRIPTION_ID_LIST" | while read -r id; do
	curl -X POST -H "Authorization: $TOKEN" -d '{"query":"mutation UpdateSubscription($id: ID!) {\n  updateSubscription(id: $id) {\n    id\n  }\n}","variables":{"id":"'"$id"'"},"operationName":"UpdateSubscription"}' $GRAPHQL_URL
	done
}

reload() {
	curl -X POST -H "Authorization: $TOKEN" -d '{"query":"mutation Run($dry: Boolean!) {\n  run(dry: $dry)\n}","variables":{"dry":false},"operationName":"Run"}' $GRAPHQL_URL
}

resetcron() {
  touch $CRON_FILE
  sed -i '/daed-next_sub.sh/d' $CRON_FILE 2>/dev/null
  [ "$(uci -q get daed-next.config.subscribe_auto_update)" -eq 1 ] && echo "${RANDOM_NUM} $(uci -q get daed-next.config.subscribe_update_day_time) * * $(uci -q get daed-next.config.subscribe_update_week_time) /etc/daed-next/daed-next_sub.sh >/dev/null 2>&1" >>$CRON_FILE
  crontab $CRON_FILE
}

login && update_subscription && reload && resetcron