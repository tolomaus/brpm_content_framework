#!/bin/bash
wget https://freedns.afraid.org/scripts/afraid.aws.sh.txt
read -p "Press [enter] to open afraid.aws.sh.txt -> modify GET to curl and insert the token for the new dns name (see http://freedns.afraid.org/dynamic/)..."
nano afraid.aws.sh.txt
mv afraid.aws.sh.txt /etc/cron.d/afraid.aws.sh
chmod 500 /etc/cron.d/afraid.aws.sh
sudo chown root.root /etc/cron.d/afraid.aws.sh
echo "*/2 * * * * root /etc/cron.d/afraid.aws.sh >/dev/null 2>&1" >> /etc/crontab
read -p "What is the dns name?" dnsname
sed -c -i "s/\(HOSTNAME *= *\).*/\1$dnsname/" /etc/sysconfig/network