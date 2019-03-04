#!/bin/bash

###########################################
#
# Here all variables for all scripts
#
###########################################

###############################
## general vars
###############################

export ORACLE_SID=TESTDB
export MKDIR_DB_PATH1="/u01/oracle/oradata/TESTDB1";
export MKDIR_FRA_PATH="/u01/oracle/fast_recovery_area/TESTDB1";

# backup dir for standby
export MKDIR_BACKUP_PATH="/u01/oracle/backup";

# backup dir for restore & recovery
export MKDIR_BACKUP2_PATH="/u01/backup_db";

###############################
## need to change after switch
###############################
export PRIMARY_HOST=srv-test-ora01
export STANDBY_HOST=srv-test-ora02
export OBSERVER_HOST=NO
export PRIMARY_UNIQ_DB_NAME=TESTDB1
export STANDBY_UNIQ_DB_NAME=TESTDB2



###############################
## remote host for test restore
###############################
export REMOTE_HOST=10.0.48.6
export REMOTE_HOST_DIR=/u01/backup/TESTDB


###############################
## general vars
###############################

#export ORACLE_BASE=/opt/oracle
#export ORACLE_HOME=/opt/oracle/app/product/12102/dbhome_1
#export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export NLS_DATE_FORMAT="HH24:MI:SS DD.MM.YYYY"
#export PATH=$PATH:$ORACLE_HOME/bin:/bin:/usr/bin
export LOCAL_HOST_NAME=`hostname`

export ALL_SCRIPTS_PATH=`pwd -P`
export date_format="%d%m%y-%H%M%S"
export begin_date=`date +$date_format`


###############################
## proc for output to screen and logs
###############################
show_hosts_db_names() {
echo "PRIMARY HOST NAME : $PRIMARY_HOST";
echo "STANDBY HOST NAME : $STANDBY_HOST";
#--> echo "OBSERVER HOST NAME: $OBSERVER_HOST";
echo "\$ORACLE_SID       : $ORACLE_SID"; 
echo "PRIMARY DB NAME   : $PRIMARY_UNIQ_DB_NAME";
echo "STANDBY DB NAME   : $STANDBY_UNIQ_DB_NAME";
}


###############################
## for 01_ssh_conf.sh
###############################
RSA_FILE_NAME=id_rsa
DSA_FILE_NAME=id_dsa
SSH_KEY_DIR=".ssh"
PUB_KEYS_FILE="authorized_keys"


###############################
## for 02_cr_dirs.sh
###############################
#export MKDIR_DB_PATH1="/u01/app/oracle/oradata/etalon2";
export MKDIR_DB_PATH2="${MKDIR_DB_PATH1}";
export MKDIR_DB_PATH3="${MKDIR_DB_PATH1}";
#export MKDIR_FRA_PATH="/u01/app/oracle/fast_recovery_area/ETALON2";
export MKDIR_HOTBACKUP_PATH="${MKDIR_BACKUP_PATH}/backupset";
export MKDIR_ARCH_LOGS_PATH="${MKDIR_BACKUP_PATH}/archivelogs";

export MKDIR_PFILE_PATH="$ORACLE_BASE/admin/$ORACLE_SID/pfile";
export MKDIR_AUDIT_PATH="$ORACLE_BASE/admin/$ORACLE_SID/adump";
export MKDIR_LIST="$MKDIR_DB_PATH1 $MKDIR_DB_PATH2 $MKDIR_DB_PATH3 $MKDIR_ARCH_LOGS_PATH $MKDIR_FRA_PATH $MKDIR_PFILE_PATH $MKDIR_AUDIT_PATH $MKDIR_HOTBACKUP_PATH";
#export MKDIR_LIST_HOTBACK_HOST="/u01/oracle/fast_recovery_area/ONKOLOGDB/ONKOLOGDB/backupset";


##################################
## for 05_hotbackup_primary.sh
## for 05_hotbackup_standby.sh
## for 05_backup_archlogs_primary.sh
##################################
if [ $LOCAL_HOST_NAME == $PRIMARY_HOST ]; then
    export REMOTE_HOST_NAME=$STANDBY_HOST;
	export HOTBACKUP_DIR_PREFIX="hotbackup_primary";
	export ARCHLOGS_BACKUP_DIR_PREFIX="archlogs_backup_primary";
	export BACKUP_FILE_PREFIX="primary";

elif [ $LOCAL_HOST_NAME == $STANDBY_HOST ]; then
    export REMOTE_HOST_NAME=$PRIMARY_HOST;
	export HOTBACKUP_DIR_PREFIX="hotbackup_standby";
	export ARCHLOGS_BACKUP_DIR_PREFIX="archlogs_backup_standby";
	export BACKUP_FILE_PREFIX="standby";

fi

export HOTBACKUP_PATH="$MKDIR_HOTBACKUP_PATH"/"$begin_date"_"$HOTBACKUP_DIR_PREFIX";
export HOTBACKUP_LOG="$HOTBACKUP_PATH"/"$HOTBACKUP_DIR_PREFIX"_"$begin_date".log
export ARCHLOGS_BACKUP_PATH="$MKDIR_HOTBACKUP_PATH"/"$begin_date"_"$ARCHLOGS_BACKUP_DIR_PREFIX";
export ARCHLOGS_BACKUP_LOG="$ARCHLOGS_BACKUP_PATH"/"$ARCHLOGS_BACKUP_DIR_PREFIX"_"$begin_date".log


# for backup all config files
export LISTENER_ORA=$ORACLE_HOME/network/admin/listener.ora
export TNSNAMES_ORA=$ORACLE_HOME/network/admin/tnsnames.ora
export SQLNET_ORA=$ORACLE_HOME/network/admin/sqlnet.ora
export PFILE_ORA=$ORACLE_HOME/dbs/init$ORACLE_SID.ora
export SPFILE_ORA=$ORACLE_HOME/dbs/spfile$ORACLE_SID.ora


# При бэкапе на standby - сервере
# можно не заполнять
#-> export BACKUP_HOST_NAME="is038-oasdt-db-03 ";
#-> export BACKUP_HOST_HOTBACKUP_PATH=/data/backupset;
#-> export BACKUP_HOST_ARCHLOGS_BACKUP_PATH=/data/backupset;

##################################
## for 08_add_standby_logs.sh
##################################
#export STANDBY_LOG_FILE_PATH=/data/oradata/deptrans/  # ! mast ended /
export STANDBY_LOG_FILE_PATH=${MKDIR_DB_PATH1}/  # ! mast ended /

##################################
## for 09_cr_orapdw_primary.sh
##################################
export ENTRIES_NUMBER=5
export SYS_PWD="NULL"

##################################
## for 12_cr_broker_cfg_primary.sh
##################################
export BROKER_CR_CONF_LOG=$ORACLE_HOME/dbs/broker_primary_cr_$ORACLE_SID_$begin_date.log
export SYS_PWD="NULL"
export BROKER_START_WAIT_SECONDS=60
export SWITCH_TRHESHOLD_SECONDS=45
export STANDBY_ARCHLOGS_LOCATION=$MKDIR_ARCH_LOGS_PATH
export PRIMARY_DB_ALIAS=$PRIMARY_UNIQ_DB_NAME
export STANDBY_DB_ALIAS=$STANDBY_UNIQ_DB_NAME


##################################
## for 13_start_observer_bg.sh
##################################
export OBSERVER_START_LOG=$ORACLE_HOME/dbs/observer_start_$begin_date.log
export SYS_PWD="NULL"


##################################
## for service check
##################################
export SERVICE_NAME=OAS


##################################
## for test data create
##################################
export TST_USR_NAME=dg_test_user
export TST_USR_PWD=qqq
export TST_TABLE_NAME=t1
export DB_ROLE="NULL"
export DB_OPEN_MODE="NULL"

