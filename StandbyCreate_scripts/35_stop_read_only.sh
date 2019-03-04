#!/bin/bash

######################################
#
# stop read only standby db
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

DB_OPEN_MODE=`$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select open_mode from v\\$database;
exit;
EOF`

echo "database open mode: .$DB_OPEN_MODE."

if [ ! "$DB_OPEN_MODE" = "READ ONLY" ]; then
	echo "AHTUNG!!!: Database open mode is not read only";
	echo "open mode mast be READ ONLY";
	echo "Exit...";
	exit;
fi


$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 150
set pagesize 1500
show parameter unique_name
shutdown immediate;
exit;
EOF
