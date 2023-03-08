# NOTE: Change the passowrd for MariaDb encryption below from SECRET

FROM ubuntu:bionic

# Mirros: http://ftp.acc.umu.se/ubuntu/ http://us.archive.ubuntu.com/ubuntu/
#RUN echo "deb http://ftp.acc.umu.se/ubuntu/ trusty-updates main restricted" > /etc/apt/sources.list

RUN apt-get update
RUN apt-get install -y wget nano curl git telnet rsyslog mytop
ADD ./etc-rsyslog.conf /etc/rsyslog.conf


RUN apt-get install -y apache2
RUN apt-get install -y apache2 php5 php5-curl php5-mysql php5-mcrypt php5-gd
RUN php5enmod mcrypt
RUN a2enmod rewrite

# See https://downloads.mariadb.org/mariadb/repositories for more mirrors
# Install MariaDB using Swedish mirror
RUN apt-get install -y software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
RUN add-apt-repository 'deb [arch=amd64,i386] http://ftp.ddg.lth.se/mariadb/repo/10.1/ubuntu trusty main'
#RUN add-apt-repository 'deb [arch=amd64,i386] http://lon1.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu trusty main'

RUN apt-get update -y
RUN apt-get install -y mariadb-server

RUN /bin/bash -c 'echo -e "#Key file\n1;$(openssl rand -hex 32)" > /keys.txt'
RUN openssl enc -aes-256-cbc -md sha1 -k SECRET -in keys.txt -out keys.enc
RUN rm /keys.txt

RUN apt-get install -y python-mysqldb
ADD ./openark-kit-196-1.deb /
RUN dpkg -i /openark-kit-196-1.deb 

RUN apt-get install -y libterm-readkey-perl libio-socket-ssl-perl
ADD ./percona-toolkit.deb /
RUN dpkg -i /percona-toolkit.deb

ADD ./etc-mysql-my.cnf /etc/mysql/my.cnf

RUN apt-get install -y python python-setuptools
RUN easy_install supervisor
ADD ./etc-supervisord.conf /etc/supervisord.conf
ADD ./etc-supervisor-conf.d-supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor/

RUN apt-get install -y groff
RUN easy_install pip
RUN pip install awscli

ADD ./daily.sh /
ADD ./monthly.sh /
RUN echo '0 1 * * *  /bin/bash -c "/daily.sh > /var/log/daily.log 2>&1"' > /mycron
RUN echo '0 0 1 * *  /bin/bash -c "/monthly.sh > /var/log/monthly.log 2>&1"' >> /mycron
RUN crontab /mycron

# update mysql driver for PHP
RUN apt-get remove -y php5-mysql
RUN apt-get install -y php5-mysqlnd
