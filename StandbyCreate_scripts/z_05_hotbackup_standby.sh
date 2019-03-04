#!/bin/bash

###########################################################
#
# hotbackup standby db
#
###########################################################

source /home/oracle/scripts/00_shell_sql_rman/00_all_vars.sh

if [ ! -d $HOTBACKUP_PATH ]; then
	mkdir -p $HOTBACKUP_PATH;
fi


echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG
echo "* BEGIN STANDBY HOTBACKUP SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"			>> $HOTBACKUP_LOG
echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG

echo                >> $HOTBACKUP_LOG;
show_hosts_db_names >> $HOTBACKUP_LOG;
echo                >> $HOTBACKUP_LOG;


$ORACLE_HOME/bin/rman target/ nocatalog log=$HOTBACKUP_LOG append >> $HOTBACKUP_LOG 2>&1 <<EOF
configure snapshot controlfile name to '$HOTBACKUP_PATH/snapshot_controlfile.f'; 
configure device type Disk backup type to compressed backupset parallelism 20;
configure channel device type Disk maxpiecesize=10G; 
configure backup optimization on; 
configure controlfile autobackup off; 
show all;
run {
	set command id to 'STANDBY_HOTBACKUP'; 
	backup full database format '$HOTBACKUP_PATH/%d_%I_$BACKUP_FILE_PREFIX\_datafile_%s_%p_%D.%M.%Y.bak' 
		noexclude include current controlfile tag 'STANDBY_HOTBACKUP_DB' 
			plus archivelog format '$HOTBACKUP_PATH/%d_%I_%e_$BACKUP_FILE_PREFIX\_archlogs_%s_%p_%D.%M.%Y.bak' tag 'STANDBY_HOTBACKUP_ARCH' delete input;
	backup current controlfile format '$HOTBACKUP_PATH/%d_%I_standby_controlfile_%s_%p_%D.%M.%Y.bak' tag 'STANDBY_HOTBACKUP_STNDB_CTL';
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

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# report obsolete                               #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
report obsolete device type disk; 

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# delete expired backup                         #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
delete noprompt expired backup of database device type disk; 

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# delete expired controlfile                    #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
delete noprompt expired backup of controlfile device type disk; 

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# delete obsolete                               #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
delete noprompt obsolete device type disk;

host '
echo "#################################################" >> $HOTBACKUP_LOG;
echo "# list backup                                   #" >> $HOTBACKUP_LOG;
echo "#################################################" >> $HOTBACKUP_LOG';
list backup;
report schema;
exit;
EOF

###################################################
# here begin backup local and remote config files
###################################################
echo "Begin backup config files ..." >> $HOTBACKUP_LOG
echo "LOCAL HOST NAME  - $LOCAL_HOST_NAME" >> $HOTBACKUP_LOG;
echo "REMOTE HOST NAME - $REMOTE_HOST_NAME" >> $HOTBACKUP_LOG;

mkdir $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
mkdir $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;

echo "copy local config files ..." >> $HOTBACKUP_LOG
cp $LISTENER_ORA $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $TNSNAMES_ORA $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $SQLNET_ORA   $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $PFILE_ORA    $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
cp $SPFILE_ORA   $HOTBACKUP_PATH/$LOCAL_HOST_NAME >> $HOTBACKUP_LOG 2>&1;

#echo "copy remote config files ..." >> $HOTBACKUP_LOG
scp $REMOTE_HOST_NAME:$LISTENER_ORA $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$TNSNAMES_ORA $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$SQLNET_ORA   $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$PFILE_ORA    $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
scp $REMOTE_HOST_NAME:$SPFILE_ORA   $HOTBACKUP_PATH/$REMOTE_HOST_NAME >> $HOTBACKUP_LOG 2>&1;
echo  >> $HOTBACKUP_LOG

###################################################
# here begin copy backup to remote backup host
###################################################
echo "beging copy hotback to remote backup host" >> $HOTBACKUP_LOG
scp -r $HOTBACKUP_PATH $BACKUP_HOST_NAME:$BACKUP_HOST_HOTBACKUP_PATH >> $HOTBACKUP_LOG 2>&1;
echo "end copy hotback to remote backup host" >> $HOTBACKUP_LOG

echo  >> $HOTBACKUP_LOG
echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG;
echo "* END STANDBY HOTBACKUP SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"				>> $HOTBACKUP_LOG;
echo "*******************************************************************************************************" 	>> $HOTBACKUP_LOG;
echo  >> $HOTBACKUP_LOG

###################################################
# get backup dir size on local and remote hosts
###################################################
echo "backup dir size on local host"                       >> $HOTBACKUP_LOG;
echo "du -ks $HOTBACKUP_PATH"                              >> $HOTBACKUP_LOG;
du -ks $HOTBACKUP_PATH                                     >> $HOTBACKUP_LOG;
echo "backup dir size on remote backup host"               >> $HOTBACKUP_LOG;
echo "du -ks $BACKUP_HOST_NAME:$HOTBACKUP_PATH"            >> $HOTBACKUP_LOG;
ssh $BACKUP_HOST_NAME "du -ks $BACKUP_HOST_HOTBACKUP_PATH" >> $HOTBACKUP_LOG 2>&1;
echo  >> $HOTBACKUP_LOG


