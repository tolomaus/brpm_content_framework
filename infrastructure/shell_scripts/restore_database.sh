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

echo "Restoring database from /root/database_backups/brpm_database_dump_$DATE.sql to $TARGET_DB_NAME..."
$BRPM_HOME/pgsql/bin/psql -U $BRPM_DB_USER -d $BRPM_DB_NAME -f $DUMP_FILE

echo "Done."