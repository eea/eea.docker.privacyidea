#FROM python:3.7
FROM ubuntu:18.04

MAINTAINER michimau <mauro.michielon@eea.europa.eu>

RUN apt-get update && apt-get install \
  -y --no-install-recommends python3 virtualenv vim

RUN apt-get -y install libjpeg-dev libz-dev python-dev libffi-dev libssl-dev libxslt1-dev libpq-dev
RUN apt-get -y install libapache2-mod-wsgi apache2
RUN python3 -m virtualenv --python=/usr/bin/python /opt/privacyidea

RUN . /opt/privacyidea/bin/activate && pip install privacyidea

RUN . /opt/privacyidea/bin/activate && pip install -r /opt/privacyidea/lib/privacyidea/requirements.txt

RUN rm /etc/apache2/sites-available/*.conf
ADD privacyidea.conf /etc/apache2/sites-available/privacyidea.conf
RUN a2enmod headers && a2enmod auth_digest && a2ensite privacyidea

RUN useradd -r -U -d '/opt/privacyidea/etc/privacyidea' -c 'privacyidea user' privacyidea -s /bin/bash

RUN . /opt/privacyidea/bin/activate && pi-manage create_enckey
RUN . /opt/privacyidea/bin/activate && pi-manage create_audit_keys

RUN . /opt/privacyidea/bin/activate && pi-manage createdb
RUN . /opt/privacyidea/bin/activate && pi-manage admin add admin -e admin@localhost --password qwerty
ADD pi.cfg /opt/privacyidea/etc/privacyidea
RUN touch /opt/privacyidea/etc/privacyidea/privacyidea.log && \
    chown privacyidea:privacyidea /opt/privacyidea/etc/privacyidea/privacyidea.log
EXPOSE 5001 5000 80
#CMD '/usr/sbin/apachectl start'
# && tail -f /var/logs/apache2/*"
