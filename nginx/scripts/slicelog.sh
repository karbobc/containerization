#!/usr/bin/env sh

set -e

MAX_BACKUP_COUNT=15

ACCESS_LOG_FILE=$(grep "access_log" /etc/nginx/nginx.conf | tr -d ";" | awk '{print $2}')
ERROR_LOG_FILE=$(grep "error_log" /etc/nginx/nginx.conf | tr -d ";" | awk '{print $2}')
PID_FILE=$(grep "nginx.pid" /etc/nginx/nginx.conf | tr -d ";" | awk '{print $2}')

ACCESS_LOG_PATH=$(dirname "$ACCESS_LOG_FILE")
ERROR_LOG_PATH=$(dirname "$ERROR_LOG_FILE")

ACCESS_LOG_BACKUP_PATH="$ACCESS_LOG_PATH/backup_access_log"
ERROR_LOG_BACKUP_PATH="$ERROR_LOG_PATH/backup_error_log"


clean() {
  # clean files when out of `MAX_BACKUP_COUNT`
  rm -f $(ls -t "$1" | tail -n +$(expr $MAX_BACKUP_COUNT + 1) | awk -v path="$1" '{print path"/"$0}')
}

backup() {
  # backup access log file
  while [ -s "$ACCESS_LOG_FILE" ]; do
    current_date=$(date -d $(head -n 1 "$ACCESS_LOG_FILE" | awk '{gsub(/\[|\]/, "", $4); print $4}') "+%Y-%m-%d")
    line=$(awk -v date="$current_date" '{if($4 !~ date) {print NR-1; exit;}}' "$ACCESS_LOG_FILE")
    if [ -z "$line" ]; then
      break
    fi
    head -n "$line" "$ACCESS_LOG_FILE" | tee -a "$ACCESS_LOG_BACKUP_PATH/$(date -d $current_date '+%Y_%m_%d').log" > /dev/null
    sed -i "1,$line"d "$ACCESS_LOG_FILE" > /dev/null
  done
  # backup error log file
  while [ -s "$ERROR_LOG_FILE" ]; do
    current_date=$(date -d $(head -n 1 "$ERROR_LOG_FILE" | awk '{print $1}') "+%Y/%m/%d")
    line=$(awk -v date="$current_date" '{if($1 != date) {print NR-1; exit;}}' "$ERROR_LOG_FILE")
    if [ -z "$line" ]; then
      break
    fi
    head -n "$line" "$ERROR_LOG_FILE" | tee -a "$ERROR_LOG_BACKUP_PATH/$(date -d $current_date '+%Y_%m_%d').log" > /dev/null
    sed -i "1,$line"d "$ERROR_LOG_FILE" > /dev/null
  done
}

# maintain backup file less than or equal to `MAX_BACKUP_COUNT`
main() {
  # create backup folder when it's empty
  if [ ! -d "$ACCESS_LOG_BACKUP_PATH" ]; then
    mkdir -p "$ACCESS_LOG_BACKUP_PATH"
  fi

  if [ ! -d "$ERROR_LOG_BACKUP_PATH" ]; then
    mkdir -p "$ERROR_LOG_BACKUP_PATH"
  fi
  # backup
  backup
  # clean up redundant log files
  clean "$ACCESS_LOG_BACKUP_PATH"
  clean "$ERROR_LOG_BACKUP_PATH"
  # send a USR1 signal that will reopen the nginx log file
  kill -USR1 "$(cat $PID_FILE)"
}

main "$@"