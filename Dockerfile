FROM        alpine:3.3

MAINTAINER	Dmitry Gopkalo <dmitry.gopkalo@tonicforhealth.com>

ENV         CONTAINER_BIN_DIR  /var/lib/health_board/bin
ENV         PATH               ${CONTAINER_BIN_DIR}/:$PATH
ENV         CONTAINER_ENV DEV   # TEST, DEV, PROD, ALL
ARG         BRANCH_OR_TAG_NAME
ENV         BRANCH_OR_TAG_NAME ${BRANCH_OR_TAG_NAME:-v0.1.0}
ARG         GIT_REPO_URL_LINK
ENV         GIT_REPO_URL_LINK ${GIT_REPO_URL_LINK:-https://github.com/tonicforhealth/health-checker-incident.git}
ENV         PHP_DATE_TIMEZONE=Europe\\/Kiev \
            CONTAINER_WORKDIR_NAME=health-checker-incident

RUN \
            apk --update add \
               bash \
               curl \
               git \
               php \
               php-iconv \
               php-zlib \
               php-ctype \
               php-json \
               php-openssl \
               php-phar \
               php-dom \
               php-pdo \
               php-pdo_sqlite \
               php-imap \
               php-fpm && \
            sed -i "s/;*date.timezone =.*/date.timezone = ${PHP_DATE_TIMEZONE}/g" /etc/php/php.ini && \
            sed -i 's/;*listen = 127.0.0.1:9000/listen = 0.0.0.0:9000/g' /etc/php/php-fpm.conf && \
            sed -i 's/;*user =.*/user = nginx/g' /etc/php/php-fpm.conf && \
            sed -i 's/;*group =.*/group = www-data/g' /etc/php/php-fpm.conf && \
            rm -rf /var/cache/apk/*

# Install composer
RUN         curl -sS https://getcomposer.org/installer \
            | php -- --install-dir=/usr/local/bin --filename=composer


RUN \
            addgroup -g 83 www-data && \
            adduser -G www-data -u 100 -D nginx

COPY		init-project.sh ${CONTAINER_BIN_DIR}/

RUN         chmod +x ${CONTAINER_BIN_DIR}/init-project.sh

WORKDIR     /var/www/${CONTAINER_WORKDIR_NAME}

RUN         chown nginx:www-data -Rf .

USER        nginx

RUN         init-project.sh download ${BRANCH_OR_TAG_NAME}

VOLUME      /var/www/${CONTAINER_WORKDIR_NAME}


EXPOSE      9000

USER        root

CMD         ["/bin/bash","-c","su nginx -c 'init-project.sh init' && /usr/bin/php-fpm --nodaemonize"]