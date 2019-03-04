#!/bin/bash

###########################################################
#
# hotbackup primary db
#
###########################################################

#-> source /home/oracle/scripts/00_shell_sql_rman/00_all_vars.sh
source 00_all_vars.sh

if [ ! -d $HOTBACKUP_PATH ]; then
	mkdir -p $HOTBACKUP_PATH;
fi


echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG
echo "* BEGIN HOTBACKUP PRIMARY SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"			>> $HOTBACKUP_LOG
echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG

echo                >> $HOTBACKUP_LOG;
show_hosts_db_names >> $HOTBACKUP_LOG;
echo                >> $HOTBACKUP_LOG;


#configure channel device type Disk maxpiecesize=10G; 

# delete input

$ORACLE_HOME/bin/rman target/ nocatalog log=$HOTBACKUP_LOG append >> $HOTBACKUP_LOG 2>&1 <<EOF
configure snapshot controlfile name to '$HOTBACKUP_PATH/snapshot_controlfile.f'; 
configure device type Disk backup type to compressed backupset parallelism 8;
configure retention policy to recovery window of 8 days; 
configure retention policy to redundancy 1; 
configure backup optimization off; 
configure controlfile autobackup on; 
show all;
run {
	sql 'alter system checkpoint';
	sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';
	set command id to 'PRIMARY_HOTBACKUP'; 
	backup full database format '$HOTBACKUP_PATH/%d_%I_$BACKUP_FILE_PREFIX\_datafile_%s_%p_%D.%M.%Y.bak' 
		noexclude include current controlfile tag 'PRIMARY_HOTBACKUP_DB'  ;
	sql 'alter system checkpoint';
	sql 'ALTER SYSTEM ARCHIVE LOG CURRENT';
	backup archivelog all format '$HOTBACKUP_PATH/%d_%I_%e_$BACKUP_FILE_PREFIX\_archlogs_%s_%p_%D.%M.%Y.bak' tag 'PRIMARY_HOTBACKUP_ARCH' ;
	backup current controlfile for standby format '$HOTBACKUP_PATH/%d_%I_standby_controlfile.bak' tag 'PRIMARY_HOTBACKUP_STNDB_CTL'; 
}
host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# crosscheck backup                             #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
crosscheck backup device type disk;  

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# crosscheck archivelog all                     #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
crosscheck archivelog all device type disk;

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# report unrecoverable                          #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
report unrecoverable device type disk; 

#host '
#echo "#################################################" >> $HOTBACKUP_LOG;
#echo "# report obsolete                               #" >> $HOTBACKUP_LOG;
#echo "#################################################" >> $HOTBACKUP_LOG';
#report obsolete device type disk; 

#host '
#echo "#################################################" >> $HOTBACKUP_LOG;
#echo "# delete expired backup                         #" >> $HOTBACKUP_LOG;
#echo "#################################################" >> $HOTBACKUP_LOG';
#delete noprompt expired backup of database device type disk; 

#host '
#echo "#################################################" >> $HOTBACKUP_LOG;
#echo "# delete expired controlfile                    #" >> $HOTBACKUP_LOG;
#echo "#################################################" >> $HOTBACKUP_LOG';
#delete noprompt expired backup of controlfile device type disk; 

#host '
#echo "#################################################" >> $HOTBACKUP_LOG;
#echo "# delete obsolete                               #" >> $HOTBACKUP_LOG;
#echo "#################################################" >> $HOTBACKUP_LOG';
#delete noprompt obsolete device type disk;

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# list backup                                   #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
list backup;
report schema;
exit;
EOF

#$ORACLE_HOME/bin/sqlplus "/ as sysdba" >> $HOTBACKUP_LOG << EOF
#set long 150
#set linesize 150
#set longchunksize 150
#set pagesize 15000
#set heading off
#select 'alter user '||username||' identified by values '||REGEXP_SUBSTR(DBMS_METADATA.get_ddl ('USER',USERNAME), '''[^'']+''')||';' from dba_users;
#exit;
#EOF

###################################################
# here begin backup local and remote config files
###################################################
echo "Begin backup config files ..." >> $HOTBACKUP_LOG
echo "LOCAL HOST NAME  - $LOCAL_HOST_NAME" >> $HOTBACKUP_LOG;
echo "REMOTE HOST NAME - $REMOTE_HOST_NAME" >> $HOTBACKUP_LOG;

mkdir $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
mkdir $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;

echo "copy local config files to backup dir ..." >> $HOTBACKUP_LOG
cp $LISTENER_ORA $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $TNSNAMES_ORA $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $SQLNET_ORA   $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $PFILE_ORA    $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $SPFILE_ORA   $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;

echo "copy config files from remote host to backup dir ..." >> $HOTBACKUP_LOG
scp $REMOTE_HOST_NAME:$LISTENER_ORA $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$TNSNAMES_ORA $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$SQLNET_ORA   $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$PFILE_ORA    $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$SPFILE_ORA   $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
echo  >> $HOTBACKUP_LOG

echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG
echo "* END HOTBACKUP PRIMARY SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"				>> $HOTBACKUP_LOG
echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG
echo  >> $HOTBACKUP_LOG

echo "Log file: ${HOTBACKUP_LOG}" 