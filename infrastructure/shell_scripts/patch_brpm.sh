#!/bin/bash

# Usage:
# patch_brpm.sh <new version> <location (ftp or local file system)>

NEW_VERSION=$1
LOCATION=$2

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the patch installation."
    exit 1
fi

if [ -z "$NEW_VERSION" ]; then
    echo "NEW_VERSION is not specified. Aborting the patch installation."
    exit 1
fi

if [ -z "$LOCATION" ]; then
    echo "The location was not specified. Aborting the installation."
    exit 1
fi

if [[ "$LOCATION" == ftp://* ]]; then
  wget -O brpm.war $LOCATION
  LOCATION=brpm.war
fi

if [ ! -f "$LOCATION" ]; then
    echo "The specified location is not a file. Aborting the installation."
    exit 1
fi

if [ -f ~/shell_scripts/backup_database.sh ]; then
    echo "Found ~/shell_scripts/backup_database.sh so taking a database backup first..."
    ~/shell_scripts/backup_database.sh
    echo ""
fi

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.6.00 stop

OLD_VERSION=$(eval "sed -n \"s=  root: $BRPM_HOME/releases/\(.*\)/RPM=\1=p\" $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml")

echo "Migrating BRPM from version $OLD_VERSION to version $NEW_VERSION... "

echo "Installing the war file ..."
mkdir -p $BRPM_HOME/releases/$NEW_VERSION/RPM
mv $LOCATION $BRPM_HOME/releases/$NEW_VERSION/RPM
cd $BRPM_HOME/releases/$NEW_VERSION/RPM
unzip -d $BRPM_HOME/releases/$NEW_VERSION/RPM $BRPM_HOME/releases/$NEW_VERSION/RPM/brpm.war

echo "Copying over the config files from $BRPM_HOME/releases/$OLD_VERSION/RPM/config ..."
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/database.yml $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/automation_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/smtp_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/wicked_pdf_config.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config
/bin/cp $BRPM_HOME/releases/$OLD_VERSION/RPM/config/carrierwave_settings.rb $BRPM_HOME/releases/$NEW_VERSION/RPM/config

if [ -d $BRPM_HOME/releases/$OLD_VERSION/RPM/lib/script_support/git_repos ]; then
  /bin/cp -R $BRPM_HOME/releases/$OLD_VERSION/RPM/lib/script_support/git_repos $BRPM_HOME/releases/$NEW_VERSION/RPM/lib/script_support
fi

echo "Replacing the version number in RPM-knob.yml ..."
sed -i -e s/$OLD_VERSION/$NEW_VERSION/g $BRPM_HOME/server/jboss/standalone/deployments/RPM-knob.yml

echo "Replacing the hostname to the public hostname in torquebox.yml ..."
PREVIOUS_HOSTNAME=$(eval "sed -n \"s=  host: \(.*\)=\1=p\" $BRPM_HOME/releases/$OLD_VERSION/RPM/config/torquebox.yml")
DEFAULT_HOSTNAME=$(eval "sed -n \"s=  host: \(.*\)=\1=p\" $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml")
sed -i -e s/$DEFAULT_HOSTNAME/$PREVIOUS_HOSTNAME/g $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml

. $BRPM_HOME/bin/setenv.sh
cd $BRPM_HOME/releases/$NEW_VERSION/RPM/config

echo "Updating gems..."
jruby -S bundle install

echo "Migrating the database..."
jruby -S rake --verbose db:migrate RAILS_ENV=production

echo "Patch $NEW_VERSION was applied successfully."
echo "Note that any customizations that may have been done to the torquebox.yml file must be redone manually: $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml"

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."

    