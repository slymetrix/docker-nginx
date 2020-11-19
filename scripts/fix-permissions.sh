#!/bin/sh
set -e

if [ -d /etc/nginx/conf ]; then
    find /etc/nginx/conf -type d -exec chmod 0755 '{}' ';'
    find /etc/nginx/conf -type f -exec chmod 0644 '{}' ';'

    if [ -d /etc/nginx/conf/certs ]; then
        find /etc/nginx/conf -type f -iname '*.key' -exec chmod 0600 '{}' ';'
    fi
fi