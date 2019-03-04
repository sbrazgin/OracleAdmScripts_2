#!/bin/bash
######################################
#
# show protection mode for Data Guard
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 150
show parameter unique_name
col DATABASE_ROLE format a20
col LOG_MODE format a10
col FLASHBACK_ON format a12
col FORCE_LOGGING format a12
col PROTECTION_MODE format a20
col PROTECTION_LEVEL format a20
select DATABASE_ROLE, LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database;
archive log list;
exit;
EOF

