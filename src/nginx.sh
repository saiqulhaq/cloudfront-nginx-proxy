#!/bin/bash

echo resolver $(awk 'BEGIN{ORS=" "} $1=="nameserver" {print $2}' /etc/resolv.conf) ";" > /etc/nginx/resolvers.conf # https://serverfault.com/a/638855

sed -i -E "s/^([\t| ]{0,})error_log.+$/\1error_log stderr warn;/" /etc/nginx/nginx.conf
sed -i -E "s/^([\t| ]{0,})access_log.+$/\1access_log off;/"       /etc/nginx/nginx.conf

echo 'Starting nginx config script...'
node /srv/config.js

echo 'Validating nginx config...'
openresty -p /var/lib/nginx -c /etc/nginx/nginx.conf -g 'daemon off;' -t
if [[ $? -ne 0 ]]; then
  echo 'nginx config validation failed, exiting...'
  exit 1
fi

echo 'Starting nginx...'
openresty -p /var/lib/nginx -c /etc/nginx/nginx.conf -g 'daemon off;' &
PID=$!

# reload on config edit
{
  while true; do
    inotifywait -r -e modify,move,create,delete /etc/nginx/
    echo 'Detected an nginx config update, running validation...'

    openresty -p /var/lib/nginx -c /etc/nginx/nginx.conf -g 'daemon off;' -t
    if [[ $? -ne 0 ]]; then
      echo 'nginx config validation failed, not reloading'
      continue
    fi

    echo 'Reloading nginx following config update...'
    kill -HUP $PID
  done
} &

wait $PID
