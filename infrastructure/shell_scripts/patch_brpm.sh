#!/bin/bash

# Usage:
# patch_brpm.sh <new version>

# Pre-conditions:
# put the brpm.war file in the home directory:
# wget <link to the brpm.war file>

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the patch installation."
    exit 1
fi

if [ -z "$NEW_VERSION" ]; then
    echo "NEW_VERSION is not set. Aborting the patch installation."
    exit 1
fi

if [ ! -f ~/brpm.war ]; then
    echo "~/brpm.war not found. Aborting the patch installation."
    exit 1
fi

if [ -f ~/backup_database.sh ]; then
    echo "Found ~/backup_database.sh so taking a database backup first..."
    ~/backup_database.sh
    echo ""
fi

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

echo "Replacing localhost to the public hostname in torquebox.yml ..."
sed -i -e s/localhost/$(hostname)/g $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml

echo "Migrating the database ..."
. $BRPM_HOME/bin/setenv.sh
cd $BRPM_HOME/releases/$NEW_VERSION/RPM/config
jruby -S rake --verbose db:migrate RAILS_ENV=production

echo "Patch $NEW_VERSION was applied successfully."
echo "Note that any customizations that may have been done to the torquebox.yml file must be redone manually: $BRPM_HOME/releases/$NEW_VERSION/RPM/config/torquebox.yml"

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.6.00 start

echo "Done."

    