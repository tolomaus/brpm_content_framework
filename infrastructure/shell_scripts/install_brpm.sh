#!/bin/bash
service iptables stop
chkconfig iptables off
yum update -y
yum install -y git wget nano curl unzip

read -p "What is the location of the RLM package? (either ftp link or local file system)" LOCATION

if [ -z "$LOCATION" ]; then
    echo "The location was not specified. Aborting the installation."
    exit 1
fi

if [[ "$LOCATION" == ftp://* ]]; then
  wget -O ./RLM.zip $LOCATION
  LOCATION=./RLM.zip
fi

if [ ! -f "$LOCATION" ]; then
    echo "The specified location is not a patch file. Aborting the installation."
    exit 1
fi

unzip $LOCATION
cd BRLM/Disk1/

read -p "What is the location of the silent install file?" SILENT_INSTALL_FILE_LOCATION

if [ ! -f "$SILENT_INSTALL_FILE_LOCATION" ]; then
    echo "The silent install file was not found. Aborting the installation."
    exit 1
fi

BRPM_HOME=$(eval "sed -n \"s/-P installLocation=\(.*\)/\1/p\" $SILENT_INSTALL_FILE_LOCATION")
if [ -z "$BRPM_HOME" ]; then
    echo "The specified location is not a silent install file. Aborting the installation."
    exit 1
fi

chmod +x setup.sh
./setup.sh -i silent -DOPTIONS_FILE=$SILENT_INSTALL_FILE_LOCATION

read -p "What is the public hostname? [$(hostname)]" EXTERNAL_HOSTNAME
CURRENT_HOSTNAME=$(hostname)
BRPM_HOSTNAME=${EXTERNAL_HOSTNAME:-$CURRENT_HOSTNAME}

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.6.00 stop

echo "Replacing the hostname to the public hostname in torquebox.yml ..."
CURRENT_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
DEFAULT_HOSTNAME=$(eval "sed -n \"s=  host: \(.*\)=\1=p\" $BRPM_HOME/releases/$CURRENT_VERSION/RPM/config/torquebox.yml")
sed -i -e s/$DEFAULT_HOSTNAME/$BRPM_HOSTNAME/g $BRPM_HOME/releases/$CURRENT_VERSION/RPM/config/torquebox.yml

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."

echo "Make sure that the BRPM and stomp ports are open."



