FROM ubuntu:xenial

RUN sh -c "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections" && \
    apt-get update -qq -y &&\
    apt-get install -y curl ca-certificates software-properties-common python-software-properties &&\
    apt-get clean &&\
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN sh -c "gpg --keyserver pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4" && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture)" && \
    curl -o /usr/local/bin/gosu.asc -SL "https://github.com/tianon/gosu/releases/download/1.6/gosu-$(dpkg --print-architecture).asc"  && \
    gpg --verify /usr/local/bin/gosu.asc &&\
    rm /usr/local/bin/gosu.asc && \
    chmod +x /usr/local/bin/gosu

ENV PHP_VERSION=7.0.14-1~dotdeb+8.1

RUN sh -c "\
    curl -s http://www.dotdeb.org/dotdeb.gpg | apt-key add - ;\
    echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list ; \
    echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list" && \
    apt-get update -qq -y &&\
    apt-get install -y tzdata locales-all "php7.0-common=$PHP_VERSION" "php7.0-json=$PHP_VERSION" "php7.0-readline=$PHP_VERSION" "php7.0-opcache=$PHP_VERSION" "php7.0-cli=$PHP_VERSION" "php7.0-dev=$PHP_VERSION" "php7.0-xml=$PHP_VERSION" "php7.0-fpm=$PHP_VERSION" "php7.0-curl=$PHP_VERSION" "php7.0-mysql=$PHP_VERSION" "php7.0-pgsql=$PHP_VERSION" "php7.0-sybase=$PHP_VERSION" php7.0-mongodb php7.0-memcached php7.0-apcu php7.0-imagick php7.0-xdebug "php7.0-mcrypt=$PHP_VERSION" --no-install-recommends &&\
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get update -qq -y && \
    apt-get --assume-yes -y -f install git zip build-essential && \
  sh -c "\
    mkdir -p /usr/local/ssl/lib; ln -s /usr/lib/x86_64-linux-gnu/libcrypto.a /usr/local/ssl/lib/libcrypto.a; \
    ln -s /usr/lib/x86_64-linux-gnu/libcrypto.so /usr/local/ssl/lib/libcrypto.so"

ENV PATH=/usr/local/bin:/bin:/usr/bin

RUN sh -c "\
    echo 'date.timezone = UTC' > /etc/php/7.0/fpm/conf.d/00-timezone.ini; \
    echo 'date.timezone = UTC' > /etc/php/7.0/cli/conf.d/00-timezone.ini;  "

CMD ["/usr/sbin/php-fpm7.0", "-F"]