#!/bin/bash

######################################
#
# create broker config
#
######################################

source 00_all_vars.sh

read -p "enter sys password for $PRIMARY_DB_ALIAS: " SYS_PWD;

if [ $SYS_PWD = "NULL" ]; then
	echo "AHTUNG! password not changed, may be read error!";
 	echo "password : $SYS_PWD";
	echo "exit ...";
fi

echo;
echo "Log file : $BROKER_CR_CONF_LOG";
echo;

echo "*******************************************************************************************************" 	>> $BROKER_CR_CONF_LOG
echo "* BEGIN CREATE BROKER CONFIG SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"            >> $BROKER_CR_CONF_LOG
echo "*******************************************************************************************************" 	>> $BROKER_CR_CONF_LOG

echo;
echo >> $BROKER_CR_CONF_LOG;
show_hosts_db_names;
show_hosts_db_names >> $BROKER_CR_CONF_LOG;
echo;
echo >> $BROKER_CR_CONF_LOG;

echo "Before create broker config, need:";
echo "Before create broker config, need:" >> $BROKER_CR_CONF_LOG;

echo "1. on primary and standby DB: alter database set standby database to maximize performance";
echo "1. on primary and standby DB: alter database set standby database to maximize performance" >> $BROKER_CR_CONF_LOG;

echo "2. on primary and standby DB: alter system set dg_broker_start=false";
echo "2. on primary and standby DB: alter system set dg_broker_start=false" >> $BROKER_CR_CONF_LOG;

echo "3. on primary and standby hosts:";
echo "   rm $ORACLE_HOME/dbs/dg_broker_config_file1/2 names get from init.ora";
echo "3. on primary and standby hosts:" >> $BROKER_CR_CONF_LOG;
echo "   rm $ORACLE_HOME/dbs/dg_broker_config_file1/2 names get from init.ora" >> $BROKER_CR_CONF_LOG;

echo "4. on primary and standby DB: alter system set dg_broker_start=true";
echo "4. on primary and standby DB: alter system set dg_broker_start=true" >> $BROKER_CR_CONF_LOG;
echo;
echo >> $BROKER_CR_CONF_LOG;


echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### dgmgrl: connect to $PRIMARY_DB_ALIAS"                           >> $BROKER_CR_CONF_LOG;
echo "#### DISABLE FAST_START FAILOVER FORCE"                              >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/dgmgrl >> $BROKER_CR_CONF_LOG <<EOF
connect sys/$SYS_PWD@$PRIMARY_DB_ALIAS
DISABLE FAST_START FAILOVER FORCE;
exit;
EOF

echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### dgmgrl: connect to $STANDBY_DB_ALIAS"                           >> $BROKER_CR_CONF_LOG;
echo "#### DISABLE FAST_START FAILOVER FORCE"                              >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/dgmgrl >> $BROKER_CR_CONF_LOG <<EOF
connect sys/$SYS_PWD@$STANDBY_DB_ALIAS
DISABLE FAST_START FAILOVER FORCE;
exit;
EOF

echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### sqlplus: connect to $PRIMARY_DB_ALIAS"                          >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$PRIMARY_DB_ALIAS as sysdba >> $BROKER_CR_CONF_LOG << EOF
set linesize 150;
host echo 'show parameter db_unique_name';
show parameter db_unique_name;
host echo 'alter database set standby database to maximize performance';
alter database set standby database to maximize performance;
host echo 'alter system set dg_broker_start=false';
alter system set dg_broker_start=false;
exit;
EOF

echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### sqlplus: connect to $STANDBY_DB_ALIAS"                          >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$STANDBY_DB_ALIAS as sysdba >> $BROKER_CR_CONF_LOG << EOF
set linesize 150;
host echo 'show parameter db_unique_name';
show parameter db_unique_name;
host echo 'alter system set dg_broker_start=false';
alter system set dg_broker_start=false;
exit;
EOF

echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### sqlplus: get value of dg_broker_config_file1/2"                 >> $BROKER_CR_CONF_LOG;
echo "####          from primary and standby db"                           >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
get_broker_cfg_file_name() {
# $1 password
# $2 db name

export tmp_var=$(
$ORACLE_HOME/bin/sqlplus -S sys/$1@$2 as sysdba << EOF
set linesize 150;
set feedback off
set heading off
select value from v\$parameter where name like 'dg_broker_config_file%';
exit;
EOF
);
export BROKER_CFG_FILES_NAMES=`echo $tmp_var|sed -e 's/\n//g'`;
}

get_broker_cfg_file_name $SYS_PWD $PRIMARY_DB_ALIAS
export PRIMARY_BROKER_CONF_FILES_NAMES=$BROKER_CFG_FILES_NAMES;

get_broker_cfg_file_name $SYS_PWD $STANDBY_DB_ALIAS
export STANDBY_BROKER_CONF_FILES_NAMES=$BROKER_CFG_FILES_NAMES;

echo "primary broker cfg files1/2 names - .$PRIMARY_BROKER_CONF_FILES_NAMES." >> $BROKER_CR_CONF_LOG;
echo "standby broker cfg files1/2 names - .$STANDBY_BROKER_CONF_FILES_NAMES." >> $BROKER_CR_CONF_LOG;

echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################"      >> $BROKER_CR_CONF_LOG;
echo "#### on $PRIMARY_HOST"         			                        >> $BROKER_CR_CONF_LOG;
echo "#### rm $PRIMARY_BROKER_CONF_FILES_NAMES"         			>> $BROKER_CR_CONF_LOG;
echo "###################################################################"      >> $BROKER_CR_CONF_LOG;
ssh $PRIMARY_HOST "rm $PRIMARY_BROKER_CONF_FILES_NAMES"                         >> $BROKER_CR_CONF_LOG 2>&1;

echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################"      >> $BROKER_CR_CONF_LOG;
echo "#### on $STANDBY_HOST"                                                    >> $BROKER_CR_CONF_LOG;
echo "#### rm $STANDBY_BROKER_CONF_FILES_NAMES"                                 >> $BROKER_CR_CONF_LOG;
echo "###################################################################"      >> $BROKER_CR_CONF_LOG;
ssh $STANDBY_HOST "rm $STANDBY_BROKER_CONF_FILES_NAMES"                         >> $BROKER_CR_CONF_LOG 2>&1;


echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### sqlplus: connect to $PRIMARY_DB_ALIAS"                          >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$PRIMARY_DB_ALIAS as sysdba >> $BROKER_CR_CONF_LOG << EOF
set linesize 150;
host echo 'show parameter db_unique_name';
show parameter db_unique_name;
host echo 'alter system set dg_broker_start=true';
alter system set dg_broker_start=true;
exit;
EOF

#--> host echo 'alter database set standby database to maximize availability';
#--> alter database set standby database to maximize availability;


echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### sqlplus: connect to $STANDBY_DB_ALIAS"                          >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/sqlplus -S sys/$SYS_PWD@$STANDBY_DB_ALIAS as sysdba >> $BROKER_CR_CONF_LOG << EOF
set linesize 150;
host echo 'show parameter db_unique_name';
show parameter db_unique_name;
host echo 'alter system set dg_broker_start=true';
alter system set dg_broker_start=true;
exit;
EOF


# wait for start broker
echo;
echo >> $BROKER_CR_CONF_LOG;
echo "wait $BROKER_START_WAIT_SECONDS seconds for start broker ... ";
echo "wait $BROKER_START_WAIT_SECONDS seconds for start broker ... " >> $BROKER_CR_CONF_LOG;
sleep $BROKER_START_WAIT_SECONDS;
echo "OK. now create broker config";
echo "OK. now create broker config" >> $BROKER_CR_CONF_LOG;


echo >> $BROKER_CR_CONF_LOG;
echo >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
echo "#### dgmgrl: connect to $PRIMARY_DB_ALIAS"                           >> $BROKER_CR_CONF_LOG;
echo "###################################################################" >> $BROKER_CR_CONF_LOG;
$ORACLE_HOME/bin/dgmgrl >> $BROKER_CR_CONF_LOG <<EOF
connect sys/$SYS_PWD@$PRIMARY_DB_ALIAS
DISABLE FAST_START FAILOVER FORCE;
REMOVE CONFIGURATION;
CREATE CONFIGURATION DG AS PRIMARY DATABASE IS $PRIMARY_DB_ALIAS CONNECT IDENTIFIER IS $PRIMARY_DB_ALIAS;
ADD DATABASE $STANDBY_DB_ALIAS AS CONNECT IDENTIFIER IS $STANDBY_DB_ALIAS ;
EDIT DATABASE '$PRIMARY_DB_ALIAS' SET PROPERTY 'StandbyArchiveLocation'='USE_DB_RECOVERY_FILE_DEST';
EDIT DATABASE '$STANDBY_DB_ALIAS' SET PROPERTY 'StandbyArchiveLocation'='USE_DB_RECOVERY_FILE_DEST';
enable configuration;
show configuration;
show database verbose '$PRIMARY_DB_ALIAS';
show database verbose '$STANDBY_DB_ALIAS';
show database '$PRIMARY_DB_ALIAS' StatusReport;
show database '$STANDBY_DB_ALIAS' StatusReport;
exit;
EOF

echo >> $BROKER_CR_CONF_LOG
echo "*******************************************************************************************************" 	>> $BROKER_CR_CONF_LOG
echo "* END CREATE BROKER CONFIG SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"		>> $BROKER_CR_CONF_LOG
echo "*******************************************************************************************************" 	>> $BROKER_CR_CONF_LOG
echo  >> $BROKER_CR_CONF_LOG

echo "Log file: ${BROKER_CR_CONF_LOG}" 
