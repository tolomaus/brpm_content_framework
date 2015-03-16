#!/bin/bash
service iptables stop
chkconfig iptables off
yum update
yum install -y wget nano curl unzip
read -p "What is the location of the RLM package?" ftp_location
wget $ftp_location > RML.zip # doesnt work: it still saves it under RLM_...zip
unzip RLM.zip
cd BRLM/Disk1/
read -p "Press [enter] to modify silent_install_options.txt..."
nano silent_install_options.txt
chmod +x setup.sh
./setup.sh -i silent -DOPTIONS_FILE=silent_install_options.txt

#TODO: make sure the $(hostname) is a publicly available url to allow the stomp stuff to work

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.6.00 stop

echo "Replacing localhost to the public hostname in torquebox.yml ..."
sed -i -e s/localhost/$(hostname)/g $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."



