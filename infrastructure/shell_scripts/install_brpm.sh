#!/bin/bash
service iptables stop
chkconfig iptables off
yum update
yum install -y wget nano curl unzip
read -p "What is the location of the RLM package?" ftp_location
wget -O RML.zip $ftp_location
unzip RLM.zip
cd BRLM/Disk1/
read -p "What is the location of the silent install file?" silent_install_file_location
chmod +x setup.sh
./setup.sh -i silent -DOPTIONS_FILE=$silent_install_file_location

echo "The hostname is $(hostname)"
read -p "Make sure the $(hostname) is a publicly available url to allow the stomp stuff to work (nano /etc/sysconfig/network), then press [enter]"

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.6.00 stop

echo "Replacing localhost to the public hostname in torquebox.yml ..."
CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
sed -i -e s/localhost/$(hostname)/g $BRPM_HOME/releases/$CURRENT_VERSION/RPM/config/torquebox.yml

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."



