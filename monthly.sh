#!/bin/bash
source /env

# backups database
FILE=$db_name-`hostname`-`date +%Y%m%d`.sql
mysqldump -h$db_server -u$db_username -p$db_password --port=3306 $db_name > /$FILE
gzip -f /$FILE
/usr/bin/aws s3 cp /$FILE.gz $backup_bucket
rm /$FILE.gz

