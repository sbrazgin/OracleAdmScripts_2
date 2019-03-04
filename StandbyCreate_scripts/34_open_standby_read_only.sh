#!/bin/bash

######################################
#
# open standby db in read only mode
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

DB_ROLE=`$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select DATABASE_ROLE from v\\$database;
exit;
EOF`

echo "database role: .$DB_ROLE."

if [ ! "$DB_ROLE" = "PHYSICAL STANDBY" ]; then
	echo "AHTUNG!!!: Database is not standby database";
	echo "database role mast be PHYSICAL STANDBY";
	echo "Exit...";
	exit;
fi

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOF
set linesize 150
set pagesize 1500
show parameter unique_name
select DATABASE_ROLE from v\$database;
host echo "## recover managed standby database cancel"
recover managed standby database cancel;
host echo "## alter database open read only"
alter database open read only;
host echo "## show open mode"
select open_mode from v\$database;
host echo "## conn $TST_USR_NAME/$TST_USR_PWD"
conn $TST_USR_NAME/$TST_USR_PWD
host echo "## select count(1) from $TST_TABLE_NAME"
select count(1) from $TST_TABLE_NAME;
exit;
EOF
