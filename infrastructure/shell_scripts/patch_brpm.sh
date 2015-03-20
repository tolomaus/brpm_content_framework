#!/bin/bash

# Usage:
# patch_brpm.sh <new version>

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the patch installation."
    exit 1
fi

if [ -z "$NEW_VERSION" ]; then
    echo "NEW_VERSION is not set. Aborting the patch installation."
    exit 1
fi

read -p "What is the location of the patch file? (either ftp link or local file system)" LOCATION

if [ -z "$LOCATION" ]; then
    echo "The location was not specified. Aborting the installation."
    exit 1
fi

if [[ "$LOCATION" == ftp://* ]]; then
  wget -O brpm.war $LOCATION
  LOCATION=brpm.war
fi

if [ ! -f "$LOCATION" ]; then
    echo "The specified location is not a patch file. Aborting the installation."
    exit 1
fi

if [ -f ~/backup_database.sh ]; then
    echo "Found ~/backup_database.sh so taking a database backup first..."
    ~/backup_database.sh
    echo ""
fi

read -p "What is the public hostname? [$(hostname)]" EXTERNAL_HOSTNAME
CURRENT_HOSTNAME=$(hostname)
BRPM_HOSTNAME=${EXTERNAL_HOSTNAME:-$CURRENT_HOSTNAME}

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.6.00 stop

OLD_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")
NEW_VERSION=$1

echo "Migrating BRPM from version $OLD_VERSION to version $NEW_VERSION... "

echo "Installing the war file ..."
mkdir -p $BRPM_HOME/releases/$NEW_VERSION/RPM
mv ~/brpm.war $BRPM_HOME/releases/$NEW_VERSION/RPM
cd $BRPM_HOME/releases/$NEW_VERSION/RPM
unzip -d $BRPM_HOME/releases/$NEW_VERSION/RPM $BRPM_HOME/releases/$NEW_VERSION/RPM/brpm.war

echo "Copying over the config files from $BRPM_HOME/releases/$OLD_VERSION/RPM/config ..."
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/database.yml $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/automation_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/smtp_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/wicked_pdf_config.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/carrierwave_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp -R $BRPM_HOME/releases/$OLD_VERSION/RPM/lib/script_support/git_repos $BRPM_HOME/releases/$NEW_VERSION/RPM/lib/script_support
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/lib/script_support/bootstrap.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/lib/script_support

echo "Replacing the version number in RPM-knob.yml ..."
sed -i -e s/$OLD_VERSION/$NEW_VERSION/g $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml

echo "Replacing the host to the public hostname in torquebox.yml ..."
CURRENT_HOSTNAME=$(eval "sed -n \"s=  host: \(.*\)=\1=p\" $BRPM_HOME/releases/$CURRENT_VERSION/RPM/config/torquebox.yml")
sed -i -e s/$CURRENT_HOSTNAME/$BRPM_HOSTNAME/g $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml

echo "Migrating the database ..."
. $BRPM_HOME/bin/setenv.sh
cd $BRPM_HOME/releases/$NEW_VERSION/RPM/config
jruby -S rake --verbose db:migrate RAILS_ENV=production

echo "Patch $NEW_VERSION was applied successfully."
echo "Note that any customizations that may have been done to the torquebox.yml file must be redone manually: $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml"

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."

    