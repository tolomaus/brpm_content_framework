#!/bin/bash
service bmcrpm-4.6.00 start
tail -F $BRPM_HOME/server/jboss/standalone/log/server.log
service bmcrpm-4.6.00 stop