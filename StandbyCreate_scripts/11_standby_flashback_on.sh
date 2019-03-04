#!/bin/bash

######################################
#
# flash back on for standby db
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 150
set pagesize 1500
show parameter unique_name;

col DATABASE_ROLE format a20
col LOG_MODE format a10
col FLASHBACK_ON format a12
col FORCE_LOGGING format a12
col PROTECTION_MODE format a20
col PROTECTION_LEVEL format a20
select DATABASE_ROLE, LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database;

host echo "#### recover managed standby database cancel"
recover managed standby database cancel;

host echo "#### alter database flashback off"
alter database flashback off;

host echo "#### alter database flashback on"
alter database flashback on;

host echo "#### to invoke real-time apply "
host echo "#### ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION"
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

select DATABASE_ROLE, LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database;

exit;
EOF
