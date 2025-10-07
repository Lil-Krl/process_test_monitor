#!/usr/bin/bash

PROC="test"
MONITOR_URL="https://test.com/monitoring/test/api"
PIDFILE="/var/lib/test_monitor/test.pid"
LOGFILE="/var/log/monitoring.log"

mkdir -p /var/lib/test_monitor
touch "$LOGFILE"

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

pid=$(pgrep -x "$PROC" | head -n1)

if [ -z "$pid" ]; then
    [ -f "$PIDFILE" ] && rm -f "$PIDFILE"
    exit 0
fi

if [ -f "$PIDFILE" ]; then
    oldpid=$(<"$PIDFILE")
    if [ "$oldpid" != "$pid" ]; then
        echo "$(timestamp) [INFO] Процесс '$PROC' перезапущен (old=$oldpid → new=$pid)" >> "$LOGFILE"
    fi
else
    echo "$(timestamp) [INFO] Процесс '$PROC' запущен (pid=$pid)" >> "$LOGFILE"
fi

echo "$pid" > "$PIDFILE"

if ! curl -fsS --max-time 5 -X POST -d "pid=$pid" "$MONITOR_URL" >/dev/null 2>&1; then
    echo "$(timestamp) [ERROR] Сервер недоступен: $MONITOR_URL" >> "$LOGFILE"
fi