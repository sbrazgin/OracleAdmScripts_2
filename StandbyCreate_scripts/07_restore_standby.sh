#!/bin/bash


######################################
#
# restore standby DB from backup
#
######################################

source 00_all_vars.sh

export RESTORE_DBID=$1
export HOTBACKUP_PATH=$2
export CONTROLFILE_NAME=$3
export RESTORE_LOG=$HOTBACKUP_PATH/restore_$begin_date.log

if [ ! $1 ] || [ ! $2 ] || [ ! $3 ]; then
	echo "Usage: $0 dbid hotbackup_path controlfile_name";
	echo "exit...";
	exit;
fi


if [ ! -d $HOTBACKUP_PATH ]; then
	echo "AHTUNG! directory don't exist: $HOTBACKUP_PATH";
	echo "exit...";
	exit;
fi

# delete if exist ending / from paths
export HOTBACKUP_PATH=`echo $HOTBACKUP_PATH|sed -e 's/\/$//g'`;
export CONTROLFILE_NAME=$HOTBACKUP_PATH/$3

if [ ! -f $CONTROLFILE_NAME ]; then
	echo "AHTUNG! file don't exist: $CONTROLFILE_NAME";
	echo "exit...";
	exit;
fi

echo;
show_hosts_db_names;
echo;

echo;
echo "Logfile: $RESTORE_LOG";
echo;

echo "*******************************************************************************************************" 	>> $RESTORE_LOG
echo "* BEGIN RESTORE SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"		                >> $RESTORE_LOG
echo "*******************************************************************************************************" 	>> $RESTORE_LOG

echo                >> $RESTORE_LOG;
show_hosts_db_names >> $RESTORE_LOG;
echo                >> $RESTORE_LOG;

echo "recreate spfile: rename old if exist and create new";
echo "recreate spfile: rename old if exist and create new" >> $RESTORE_LOG;

if [ -f $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ]; then
	echo "AHTUNG! file exist: $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora";
	echo "AHTUNG! file exist: $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora" >> $RESTORE_LOG;
	echo "rename file $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora to $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora_$begin_date";
	echo "rename file $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora to $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora_$begin_date" >> $RESTORE_LOG;
	mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora_$begin_date;
fi

echo "create spfile";
echo "create spfile" >> $RESTORE_LOG;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" >>$RESTORE_LOG <<EOF
host echo 'create spfile from pfile';
create spfile from pfile;
exit;
EOF

$ORACLE_HOME/bin/rman log=$RESTORE_LOG append >> $RESTORE_LOG 2>&1 <<EOF
set dbid $RESTORE_DBID;
connect target;
startup nomount;
run {
   restore standby controlfile from '$CONTROLFILE_NAME';
   sql 'alter database mount standby database';
   restore database;
   recover database;
}
list backup of archivelog all;
exit;
EOF

echo "*******************************************************************************************************" 	>> $RESTORE_LOG
echo "* END RESTORE SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"				>> $RESTORE_LOG
echo "*******************************************************************************************************" 	>> $RESTORE_LOG
echo  >> $RESTORE_LOG

