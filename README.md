Building
=======

Build the image: `docker build -t mariadb .`

Starting the server this way makes it possible to connect and reconnect to the
server:

    docker run -t -i -p 8090:80 \
    --restart="on-failure:10" --name mariadb -h mariadb \
    mariadb /bin/bash -c "supervisord; bash"

Exit the server with `ctrl-p` `ctrl-q`. Reconnect with `docker attach logserver`


Setup Encryption
---------------

Start with setting the mysql root password (if this hasn't been done already):
`mysqladmin -u root password NEWPASSWORD` (cahnge NEWPASSWORD to a string password, preferably random).

Encryption of tables and tablespaces with MariaDb requires version 10.1.3. Significant changes 
were made in versoin 10.1.4 so this version or higher should be used.

How to setup encryption: https://mariadb.com/kb/en/mariadb/data-at-rest-encryption/#specifying-what-tables-to-encrypt

```
# Show system variables
show status like '%enc%';

# Show engine status
show engine innodb status;
```

`help show` gives an overview of the show commands.

Setup the encryption key:

```
# Update mysql configuration
nano /etc/mysql/my.cnf

# Add  in [mysqld] section
plugin-load-add=file_key_management.so
file_key_management_encryption_algorithm=aes_cbc
file_key_management_filename = /keys.enc
file_key_management_filekey = secret

innodb-encrypt-tables
innodb-encrypt-log
innodb-encryption-threads=4
# innodb-encryption-rotate-key-age=1800

encrypt_tmp_files
encrypt-tmp-disk-tables=1
aria-encrypt-tables=1

# Create the key file
echo -e "#Key file\n1;$(openssl rand -hex 32)" > /keys.txt
openssl enc -aes-256-cbc -md sha1 -k secret -in keys.txt -out keys.enc

# Test to decrypt the file
openssl enc -aes-256-cbc -md sha1 -k secret -in keys.enc -d

# Remove the cleartext
rm /keys.txt
```



Test the encryption
-------------------

Create a encrypted table:

```
CREATE DATABASE encrypted; 
USE encrypted; 
CREATE TABLE test (id INTEGER NOT NULL PRIMARY KEY, col1 VARCHAR(100)) ENCRYPTED=YES ENCRYPTION_KEY_ID=1; 
INSERT INTO test VALUES (101, 'Hello, World!'); 
SELECT * FROM test; # data will display 
exit
```

Check the database file: `cat /var/lib/`


```
CREATE DATABASE PLAINTEXT;
USE PLAINTEXT;
CREATE TABLE test (id INTEGER NOT NULL PRIMARY KEY, col1 VARCHAR(100));
INSERT INTO test VALUES (101, 'Hello, World!');
SELECT * FROM test; # data will display
exit
```


Audit
-----


* Open Ark Kit - https://openarkkit.googlecode.com/svn/trunk/openarkkit/doc/html/oak-security-audit.html
* Securich - http://www.securich.com/ 

Run oak security audit: `oak-security-audit --user=root --ask-pass --socket=/run/mysqld/mysqld.sock --audit-level=strict`
