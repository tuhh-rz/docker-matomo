FROM ubuntu:18.04

ARG VERSION=${VERSION:-3.13.0}
ENV VERSION=$VERSION
RUN echo $VERSION

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Let the conatiner know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
RUN apt-get -y upgrade

# Requirements
RUN apt-get -y install \
    apache2 \
    cron \
    gawk \
    libapache2-mod-php \
    php-cli \
    php-curl \
    php-gd \
    php-geoip \
    php-ldap \
    php-mbstring \
    php-mysql \
    php-xml \
    python-setuptools \
    rsync \
    supervisor \
    wget

# Housekeeping
RUN apt-get clean

ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./conf/supervisord.conf /etc/supervisord.conf

# SSL
RUN mkdir -p /etc/apache2/ssl

RUN rm /etc/apache2/sites-enabled/*
ADD ./conf/default-ssl.conf /etc/apache2/sites-enabled
ADD ./conf/default.conf /etc/apache2/sites-enabled

# Matomo herunter laden
RUN wget https://builds.matomo.org/matomo-${VERSION}.tar.gz -P /tmp
# Entpacken und Archiv loeschen
RUN tar zxvf /tmp/matomo-${VERSION}.tar.gz -C /tmp && rm /tmp/matomo-${VERSION}.tar.gz

RUN chmod 755 /start.sh /etc/apache2/foreground.sh

WORKDIR /var/www/html

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]

LABEL \
    de.tuhh.ci_repository_url=$CI_REPOSITORY_URL \
    de.tuhh.ci_commit_short_sha=$CI_COMMIT_SHORT_SHA \
    de.tuhh.build-date=$BUILD_DATE \
    de.tuhh.version=$VERSION
