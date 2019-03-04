#!/bin/bash

######################################
#
# check db service
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOF
set linesize 150
set pagesize 1500
show parameter unique_name
col NAME format a20
col NETWORK_NAME format a20
col CREATION_DATE format a20
select NAME, NETWORK_NAME, to_char(CREATION_DATE,'HH24:MI:SS DD-MM-YY') CREATION_DATE, BLOCKED from V\$ACTIVE_SERVICES where name like '%$SERVICE_NAME%';

col SERVICE_NAME format a20
col STAT_NAME format a40
select SERVICE_NAME, STAT_NAME, VALUE from V\$SERVICE_STATS where service_name like '%$SERVICE_NAME%';

exit;
EOF

echo "lsnrctl service|grep -i $SERVICE_NAME";
$ORACLE_HOME/bin/lsnrctl service|grep -i $SERVICE_NAME;
echo
echo
