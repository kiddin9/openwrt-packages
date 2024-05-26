#!/bin/sh

NODE_BIN=/usr/bin/node
WEB_SQUASHFS=/usr/share/daed-next/daed-web.squashfs
PID_FILE=/tmp/log/daed-next/dashboard.pid
DAED_NEXT_DIR=/var/daed-next

start_server() {
    listen_port=$(uci -q get daed-next.config.listen_port)
    if [ ! -d "$DAED_NEXT_DIR" ]; then
        mkdir -p "$DAED_NEXT_DIR"
    fi
    mount -t squashfs "$WEB_SQUASHFS" "$DAED_NEXT_DIR" || { echo "Mount failed"; }

    ARGS="PORT=$listen_port HOSTNAME=0.0.0.0"
    /bin/sh -c "$ARGS $NODE_BIN $DAED_NEXT_DIR/server.js" &
    echo $! > "$PID_FILE"
}

stop_server() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        kill "$PID" || { echo "Failed to kill process $PID"; }
        rm -f "$PID_FILE"

        mount_points=$(mount | grep '/tmp/daed-next' | awk '{print $3}')
        for mp in $mount_points; do
            umount -l "$mp" || { echo "Failed to force unmount $mp"; }
        done
    fi
}

if [ -e "$PID_FILE" ]; then
    stop_server
else
    start_server
fi
