#!/bin/bash

if [[ ${ENABLE_SSL} == "true" ]]; then
  echo "[INFO] SSL enabled"
  sed -i '/SSLCertificateFile/d' /etc/apache2/sites-available/default-ssl.conf
  sed -i '/SSLCertificateKeyFile/d' /etc/apache2/sites-available/default-ssl.conf
  sed -i '/SSLCertificateChainFile/d' /etc/apache2/sites-available/default-ssl.conf

  sed -i 's/SSLEngine.*/SSLEngine on\nSSLCertificateFile \/etc\/apache2\/ssl\/cert.pem\nSSLCertificateKeyFile \/etc\/apache2\/ssl\/private_key.pem\nSSLCertificateChainFile \/etc\/apache2\/ssl\/cert-chain.pem/' /etc/apache2/sites-available/default-ssl.conf
  ln -s /etc/apache2/sites-available/default-ssl.conf /etc/apache2/sites-enabled/
  /usr/sbin/a2enmod ssl
else
  echo "[WARNING] SSL disabled"
  /usr/sbin/a2dismod ssl
  rm /etc/apache2/sites-enabled/default-ssl.conf
fi

rsync -rc /opt/matomo/* "/var/www/html"
chown -Rf www-data.www-data "/var/www/html"

perl -i -ne 'print unless /^# INJECTION MARKER START/ .. /^# INJECTION MARKER END/' /etc/crontab
{
  echo '# INJECTION MARKER START'
  echo "# 5 * * * * www-data /usr/bin/php /var/www/html/console core:archive --url=${MATOMO_BASE_URL}"
  echo '# INJECTION MARKER END'
} >>/etc/crontab

su -s /bin/bash -c "/usr/bin/php /var/www/html/console core:update --yes" www-data

exec /usr/bin/supervisord -n -c /etc/supervisord.conf
