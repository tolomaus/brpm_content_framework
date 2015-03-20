#! /bin/bash

if [ -z "$BRPM_HOME" ]; then
    echo "BRPM_HOME is not set (e.g. /opt/bmc/RLM). Aborting the backup."
    exit 1
fi

BRPM_DB_NAME=bmc_rpm_db
BRPM_DB_USER=rlm_user

if [ ! -d "/root/database_backups" ]; then
  mkdir -p /root/database_backups
fi

DATE=$(date +"%Y%m%d%H%M")
echo "Backing up database to /root/database_backups/brpm_database_dump_$DATE.sql..."
$BRPM_HOME/pgsql/bin/pg_dump -U $BRPM_DB_USER $BRPM_DB_NAME -f /root/database_backups/brpm_database_dump_$DATE.sql

echo "Done."