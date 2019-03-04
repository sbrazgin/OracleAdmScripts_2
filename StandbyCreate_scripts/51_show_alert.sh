#!/bin/bash

######################################
#
# open standby db in read only mode
#
######################################

source 00_all_vars.sh

export DIAG_DEST=`$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select value from v\\$parameter where name='diagnostic_dest';
exit;
EOF`

export DB_UNIQ_NAME=`$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set heading off;
set feedback off;
set pagesize 0;
set tab off;
select value from v\\$parameter where name='db_unique_name';
exit;
EOF`

export LWC_ORA_SID=`echo $ORACLE_SID | awk '{print tolower($0)}'`; 

tail -500f $DIAG_DEST/diag/rdbms/$DB_UNIQ_NAME/$ORACLE_SID/trace/alert_$LWC_ORA_SID.log
