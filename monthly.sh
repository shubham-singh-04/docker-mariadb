#!/bin/bash
source /env

FILE=`hostname`-`date +%Y%m%d`-logfiles.tgz

# rotate mysql logs and archive
rm -rf /var/log/mysql-archive
mkdir -p /var/log/mysql-archive

# create new logs
mv /var/log/mysql/* /var/log/mysql-archive
mysqladmin -h$db_server -u$db_user -p$db_password flush-logs

# copy the logs to S3
tar -czf /$FILE /var/log/mysql-archive/*
/usr/local/bin/aws s3 cp /$FILE $backup_bucket

# cleanup
rm /$FILE