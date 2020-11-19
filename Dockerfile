FROM nginx:1.19-alpine

COPY scripts/run-cron.sh /docker-entrypoint.d/99-run-cron.sh
COPY scripts/geoip.sh /docker-entrypoint.d/10-geoip.sh
COPY scripts/fix-permissions.sh /docker-entrypoint.d/99-fix-permissions.sh
COPY conf/logrotate /etc/logrotate.d/nginx
COPY conf/fastcgi_params /etc/nginx/fastcgi_params
COPY conf/cache-static.conf /etc/nginx/cache-static.conf

ENV CRON_LOGROTATE="0 4 * * *"

RUN set -eux; \
    # Add www-data group
    test "$(getent group www-data 2>/dev/null | cut -d: -f3)" = 82 || \
    addgroup -g 82 -S www-data ; \
    # Add www-data user
    test "$(id -u www-data 2>/dev/null)" = 82 || \
    adduser -S -D -H -u 82 -h /var/cache/nginx -s /sbin/nologin -G www-data -g www-data www-data; \
    # Remove nginx user and group
    chown -R www-data:www-data /var/cache/nginx; \
    deluser nginx; \
    \
    # Install needed packages
    apk add --no-cache logrotate xz; \
    rm -rf /var/cache/apk/*; \
    \
    # Remove useless configs
    rm -f /var/log/nginx/access.log /var/log/nginx/error.log; \
    rm -f /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh; \
    # Setup cron
    mkdir -p /var/log/cron; \
    mkdir -m 0644 -p /var/spool/cron/crontabs; \
    touch /var/log/cron/cron.log; \
    mkdir -m 0644 /etc/cron.d; \
    chmod +x /docker-entrypoint.d/99-run-cron.sh; \
    \
    # Setup conf
    find /etc/nginx -mindepth 1 -maxdepth 1 \
    -not \( \
    -name modules -prune -o \
    -name mime.types -prune -o \
    -name fastcgi_params -prune -o \
    -name cache-static.conf -prune \
    \) \
    -exec rm -rf '{}' ';' \
    ; \
    mkdir -m 0755 conf; \
    ln -sf /etc/nginx/conf/nginx.conf /etc/nginx/nginx.conf; \
    mkdir -m 0755 -p /etc/nginx/conf/certs; \
    chmod +x /docker-entrypoint.d/99-fix-permissions.sh; \
    # Configure logrotate
    rm -f /etc/logrotate.d/acpid; \
    # Configure geoip
    chmod +x /docker-entrypoint.d/10-geoip.sh