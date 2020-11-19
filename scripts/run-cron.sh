#!/bin/sh
set -e

rm -rf /var/spool/cron/crontabs
mkdir -m 0644 -p /var/spool/cron/crontabs

find /etc/cron.d -mindepth 1 -maxdepth 1 -exec cp -f '{}' /var/spool/cron/crontabs \;

echo >> /var/spool/cron/crontabs/root

if [ -e /etc/periodic/daily/logrotate ]; then
    chmod +x /etc/periodic/daily/logrotate
    echo "$CRON_LOGROTATE /etc/periodic/daily/logrotate" >> /var/spool/cron/crontabs/root
fi

if [ -n "$CRON_GEOIP" ]; then
    chmod +x /etc/periodic/monthly/geoip
    echo "$CRON_GEOIP /etc/periodic/monthly/geoip" >> /var/spool/cron/crontabs/root
fi

chmod -R 0644 /var/spool/cron/crontabs

exec crond -c /var/spool/cron/crontabs -b -L /var/log/cron/cron.log