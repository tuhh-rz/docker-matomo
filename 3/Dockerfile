FROM ubuntu:18.04

ARG VERSION=${VERSION}
ENV VERSION=$VERSION
RUN echo $VERSION

ARG DOWNLOAD=${DOWNLOAD}
ENV DOWNLOAD=$DOWNLOAD
RUN echo $DOWNLOAD

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
  curl \
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
RUN curl $DOWNLOAD |\
  tar -xzC /opt

RUN chmod 755 /start.sh /etc/apache2/foreground.sh

WORKDIR /var/www/html

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]

LABEL \
  de.tuhh.ci_repository_url=$CI_REPOSITORY_URL \
  de.tuhh.ci_commit_short_sha=$CI_COMMIT_SHORT_SHA \
  de.tuhh.build-date=$BUILD_DATE \
  de.tuhh.version=$VERSION
