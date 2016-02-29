#!/bin/bash
echo "usage ./sendmail fromhost mailhost from to subject message"

cat > /tmp/mail.txt <<EOL
ehlo $1
mail from: $3
rcpt to: $4
data
Subject: $5
$6
.
quit
EOL

cat /tmp/mail.txt |telnet $2 25