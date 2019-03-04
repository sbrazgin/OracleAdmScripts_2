#!/bin/bash

###########################################################
#
# archivelogs backup on primary DB 
#
###########################################################

#source /home/oracle/scripts/00_shell_sql_rman/00_all_vars.sh
source 00_all_vars.sh

if [ ! -d $ARCHLOGS_BACKUP_PATH ]; then
	mkdir -p $ARCHLOGS_BACKUP_PATH;
fi


echo "*******************************************************************************************************" 	>> $ARCHLOGS_BACKUP_LOG
echo "* BEGIN ARCHLOGS BACKUP SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"			>> $ARCHLOGS_BACKUP_LOG
echo "*******************************************************************************************************" 	>> $ARCHLOGS_BACKUP_LOG

echo                >> $ARCHLOGS_BACKUP_LOG;
show_hosts_db_names >> $ARCHLOGS_BACKUP_LOG;
echo                >> $ARCHLOGS_BACKUP_LOG;

$ORACLE_HOME/bin/rman target/ nocatalog log=$ARCHLOGS_BACKUP_LOG append >> $ARCHLOGS_BACKUP_LOG 2>&1 <<EOF
configure snapshot controlfile name to '$ARCHLOGS_BACKUP_PATH/snapshot_controlfile.f'; 
configure device type Disk backup type to compressed backupset parallelism 8;
configure channel device type Disk maxpiecesize=10G; 
configure retention policy to recovery window of 3 days; 
configure retention policy to redundancy 1; 
configure backup optimization on; 
configure controlfile autobackup off; 
show all;
run {
	set command id to 'PRIM_ARCHLOGS_BACKUP'; 
	backup archivelog all format '$ARCHLOGS_BACKUP_PATH/%d_%I_%e_$BACKUP_FILE_PREFIX\_archlogs_%s_%p_%D.%M.%Y.bak' tag 'PRIMARY_ARCHLOGS_BACKUP' delete input;
	backup current controlfile for standby format '$ARCHLOGS_BACKUP_PATH/%d_%I_standby_controlfile_%s_%p_%D.%M.%Y.bak' tag 'PRIMARY_ARCHBACKUP_STNDB_CTL'; 

}
host '
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG;
echo "# crosscheck backup                             #" >> $ARCHLOGS_BACKUP_LOG;
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG';
crosscheck backup device type disk;  

host '
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG;
echo "# crosscheck archivelog all                     #" >> $ARCHLOGS_BACKUP_LOG;
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG';
crosscheck archivelog all device type disk;

host '
echo "#######################################################################################"     >> $ARCHLOGS_BACKUP_LOG;
echo "# delete noprompt backup tag \"PRIMARY_ARCHLOGS_BACKUP\" completed before \"sysdate-3\";  #" >> $ARCHLOGS_BACKUP_LOG;
echo "#######################################################################################"     >> $ARCHLOGS_BACKUP_LOG';
delete noprompt backup tag 'PRIMARY_ARCHLOGS_BACKUP' completed before 'sysdate-3' device type disk;

host '
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG;
echo "# list backup                                   #" >> $ARCHLOGS_BACKUP_LOG;
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG';
list backup;

host '
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG;
echo "# report schema                                 #" >> $ARCHLOGS_BACKUP_LOG;
echo "#################################################" >> $ARCHLOGS_BACKUP_LOG';
report schema;
exit;
EOF

echo "*******************************************************************************************************" 	>> $ARCHLOGS_BACKUP_LOG;
echo "* END ARCHLOGS BACKUP SID=$ORACLE_SID  HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"			>> $ARCHLOGS_BACKUP_LOG;
echo "*******************************************************************************************************" 	>> $ARCHLOGS_BACKUP_LOG;
echo  >> $ARCHLOGS_BACKUP_LOG
