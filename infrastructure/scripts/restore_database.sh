#! /bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the restore."
    exit 1
fi

DUMP_FILE=$1

if [ -z "$DUMP_FILE" ]; then
    echo "DUMP_FILE is not specified. Aborting the restore."
    exit 1
fi

BRPM_DB_NAME=bmc_rpm_db
BRPM_DB_USER=rlm_user

echo "Stopping BRPM..."
/etc/init.d/bmcrpm-4.8.00 stop

echo "Dropping existing database $BRPM_DB_NAME..."
$BRPM_HOME/pgsql/bin/dropdb -U $BRPM_DB_USER $BRPM_DB_NAME

echo "Creating database $BRPM_DB_NAME..."
$BRPM_HOME/pgsql/bin/createdb -O $BRPM_DB_USER -E UTF8 -U $BRPM_DB_USER $BRPM_DB_NAME

echo "Restoring database from $DUMP_FILE to $BRPM_DB_NAME..."
$BRPM_HOME/pgsql/bin/psql -U $BRPM_DB_USER -d $BRPM_DB_NAME -f $DUMP_FILE

echo "Restarting BRPM..."
/etc/init.d/bmcrpm-4.8.00 start

echo "Done."
