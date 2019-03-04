#!/bin/bash

######################################
#
# create oracle password file on primary
# host and then copy to standby
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

echo "AHTUNG! password on primary and standby must be the same!";
read -p "enter sys password for SID=$ORACLE_SID: " SYS_PWD;

if [ $SYS_PWD = "NULL" ]; then
	echo "AHTUNG! password not changed, may be read error!";
 	echo "password : $SYS_PWD";
	echo "exit ...";
fi

echo;
echo "#### create $ORACLE_HOME/dbs/orapw$ORACLE_SID file";
$ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID password=$SYS_PWD entries=$ENTRIES_NUMBER force=y

echo;
echo "#### check created file";
ls -all $ORACLE_HOME/dbs/orapw$ORACLE_SID;
echo;

echo;
echo "#### scp $ORACLE_HOME/dbs/orapw$ORACLE_SID $STANDBY_HOST:$ORACLE_HOME/dbs/orapw$ORACLE_SID";
scp $ORACLE_HOME/dbs/orapw$ORACLE_SID $STANDBY_HOST:$ORACLE_HOME/dbs/orapw$ORACLE_SID;
echo;

echo;
echo "#### check file on $STANDBY_HOST";
ssh $STANDBY_HOST "ls -all $ORACLE_HOME/dbs/orapw$ORACLE_SID";
echo;


echo;
echo "#### check connect to primary, standby DB";
echo "$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$PRIMARY_UNIQ_DB_NAME as sysdba"
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$PRIMARY_UNIQ_DB_NAME as sysdba << EOF
set linesize 150
show parameter db_unique_name;
exit;
EOF

echo;
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$STANDBY_UNIQ_DB_NAME as sysdba << EOF
set linesize 150
show parameter db_unique_name;
exit;
EOF

