#!/bin/bash
source /env

# backups database
FILE=`hostname`-`date +%Y%m%d`.sql
mysqldump -h$db_server -u$db_user -p$db_password --port=3306 --all-databases > /$FILE
gzip -f /$FILE
/usr/local/bin/aws s3 cp /$FILE.gz $backup_bucket
rm /$FILE.gz

