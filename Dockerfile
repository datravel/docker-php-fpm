FROM debian:jessie

MAINTAINER Ilya Epifanov <elijah.epifanov@gmail.com>

RUN apt-get update \
 && apt-get install -y curl ca-certificates software-properties-common python-software-properties \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" \
        && curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc" \
        && gpg --verify /usr/local/bin/gosu.asc \
        && rm /usr/local/bin/gosu.asc \
        && chmod +x /usr/local/bin/gosu

RUN curl -s http://www.dotdeb.org/dotdeb.gpg | apt-key add -

ENV PHP_VERSION=5.6.19

RUN apt-get update \
 && apt-get install -y tzdata locales-all "php5-cli=$PHP_VERSION+*" "php5-fpm=$PHP_VERSION+*" "php5-curl=$PHP_VERSION+*" "php5-mysqlnd=$PHP_VERSION+*" "php5-pgsql=$PHP_VERSION+*" "php5-gd=$PHP_VERSION+*" php5-mongo php5-memcache php5-apcu "php5-intl=$PHP_VERSION+*" php5-xdebug php5-imagick php5-mcrypt --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV AEROSPIKE_VERSION=3.4.2

RUN curl -sL --raw https://github.com/aerospike/aerospike-client-php/archive/${AEROSPIKE_VERSION}.tar.gz -o /tmp/aerospike.tar.gz \
 && mkdir /tmp/aerospike \
 && tar zxf /tmp/aerospike.tar.gz --strip-components=1 -C /tmp/aerospike \
 && cd /tmp/aerospike/src/aerospike \
 && apt-get update \
 && apt-get install -y build-essential autoconf libssl-dev liblua5.1-dev "php5-dev=$PHP_VERSION+*" "php-pear=$PHP_VERSION+*" --no-install-recommends \
 && AEROSPIKE_C_CLIENT=3.1.24 ./build.sh \
 && make install \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN export VERSION=`php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;"` \
    && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/${VERSION} \
    && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
    && mv /tmp/blackfire-*.so `php -r "echo ini_get('extension_dir');"`/blackfire.so \
    && echo "extension=blackfire.so\nblackfire.agent_socket=\${BLACKFIRE_PORT}" > /etc/php5/fpm/conf.d/00-blackfire.ini

ENV PATH=/usr/local/bin:/bin:/usr/bin

RUN echo 'date.timezone = UTC' > /etc/php5/fpm/conf.d/00-timezone.ini
RUN echo 'date.timezone = UTC' > /etc/php5/cli/conf.d/00-timezone.ini
ADD aerospike.ini /etc/php5/fpm/conf.d/00-aerospike.ini
ADD aerospike.ini /etc/php5/cli/conf.d/00-aerospike.ini

CMD ["/usr/sbin/php5-fpm", "-F"]
