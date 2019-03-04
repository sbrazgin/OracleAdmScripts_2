#!/bin/bash

######################################
#
# check broker errors
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

export SYS_PWD_1="NULL"
export SYS_PWD_2="NULL"

export DB_ALIAS_1=$PRIMARY_UNIQ_DB_NAME
export DB_ALIAS_2=$STANDBY_UNIQ_DB_NAME

read -p "enter sys password for $DB_ALIAS_1: " SYS_PWD_1;
read -p "enter sys password for $DB_ALIAS_2: " SYS_PWD_2;

if [ $SYS_PWD_1 = "NULL" ]; then
	echo "AHTUNG! password not changed, may be read error!";
 	echo "password : $SYS_PWD_1";
	echo "exit ...";
fi

if [ $SYS_PWD_2 = "NULL" ]; then
	echo "AHTUNG! password not changed, may be read error!";
 	echo "password : $SYS_PWD_2";
	echo "exit ...";
fi


$ORACLE_HOME/bin/dgmgrl <<EOF
connect sys/$SYS_PWD_1@$DB_ALIAS_1
show configuration verbose;
show database verbose '$DB_ALIAS_1';
show database '$DB_ALIAS_1' StatusReport;
exit;
EOF

$ORACLE_HOME/bin/dgmgrl <<EOF
connect sys/$SYS_PWD_1@$DB_ALIAS_2
show configuration verbose;
show database verbose '$DB_ALIAS_2';
show database '$DB_ALIAS_2' StatusReport;
exit;
EOF

echo;

