#!/bin/sh
set -e

if [ -n "$CRON_GEOIP" -a -e /etc/periodic/monthly/geoip ]; then
    if [ ! -e /usr/share/GeoIP/GeoIP.dat -o \
        ! -e /usr/share/GeoIP/GeoIPv6.dat -o \
        ! -e /usr/share/GeoIP/GeoLiteCity.dat \
        ! -e /usr/share/GeoIP/GeoLiteCityv6.dat -o \
        ! -e /usr/share/GeoIP/GeoIPASNum.dat -o \
        ! -e /usr/share/GeoIP/GeoIPASNumv6.dat ]; then
        chmod +x /etc/periodic/monthly/geoip
        /etc/periodic/monthly/geoip
    fi
fi