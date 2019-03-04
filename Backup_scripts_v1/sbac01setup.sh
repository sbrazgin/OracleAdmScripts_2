#!/bin/bash 

########################################################################
# author: Sergey Brazgin     sbrazgin@gmail.com
# 
# 1) create dirs
# 2) create copy file (easy)
# 3) create oraenv
# 4) config rman
# 5) create scp copy script
########################################################################


cd /home/oracle/scripts
source 00_all_vars.sh

export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
export date=`date +%Y%m%d%H%M%S`
export date1=`date +%Y_%m_%d`
export date2=`date +%H_%M_%S`

#---------------- create dirs
export PATH_TO_FILES="${MKDIR_BACKUP2_PATH}"
echo "PATH_TO_FILES=${PATH_TO_FILES}"
[ -d $PATH_TO_FILES ] || mkdir -p $PATH_TO_FILES

export PATH_TO_BACKUP="${MKDIR_BACKUP2_PATH}/backup"
echo "PATH_TO_BACKUP=${PATH_TO_BACKUP}"
[ -d $PATH_TO_BACKUP ] || mkdir -p $PATH_TO_BACKUP

export PATH_TO_LOGS=${MKDIR_BACKUP2_PATH}/logs
echo "PATH_TO_LOGS=${PATH_TO_LOGS}"
[ -d $PATH_TO_LOGS ] || mkdir -p $PATH_TO_LOGS

export PATH_TO_TMP=${MKDIR_BACKUP2_PATH}/temp
echo "PATH_TO_TMP=${PATH_TO_TMP}"
[ -d $PATH_TO_TMP ] || mkdir -p $PATH_TO_TMP

export LOGOUT=$PATH_TO_LOGS/$date1
echo "CURRENT_LOGS=${LOGOUT}"
[ -d $LOGOUT ] || mkdir -p $LOGOUT

#---------------- create files
ORAENV_FILE_NAME="${PATH_TO_FILES}/oraenv.sh"
RMAN_CONFIG_FILE_NAME="${PATH_TO_TMP}/config.rman"

# create oraenv file for crontab
echo "export ORACLE_BASE=${ORACLE_BASE}" > ${ORAENV_FILE_NAME}
echo "export ORACLE_HOME=${ORACLE_HOME}" >> ${ORAENV_FILE_NAME}
echo "export ORACLE_SID=${ORACLE_SID}" >> ${ORAENV_FILE_NAME}
echo "export LD_LIBRARY_PATH=${ORACLE_HOME}/lib:" >> ${ORAENV_FILE_NAME}
echo "export PATH=/usr/local/bin:/bin:/usr/bin:/home/oracle/bin:/home/oracle/bin:${ORACLE_HOME}/bin:" >> ${ORAENV_FILE_NAME}
echo "created: ${ORAENV_FILE_NAME}"

# config rman options
echo "CONFIGURE BACKUP OPTIMIZATION ON;" > ${RMAN_CONFIG_FILE_NAME}
echo "CONFIGURE DEFAULT DEVICE TYPE TO DISK;" >> ${RMAN_CONFIG_FILE_NAME}
echo "CONFIGURE CONTROLFILE AUTOBACKUP ON;" >> ${RMAN_CONFIG_FILE_NAME}
echo "CONFIGURE CHANNEL DEVICE TYPE DISK FORMAT '${PATH_TO_BACKUP}/DB_%d_%U';" >> ${RMAN_CONFIG_FILE_NAME}
echo "CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '${PATH_TO_BACKUP}/control_%d_%F.ctl'; " >> ${RMAN_CONFIG_FILE_NAME}
echo "CONFIGURE SNAPSHOT CONTROLFILE NAME TO '${PATH_TO_BACKUP}/snap_control.ctl';" >> ${RMAN_CONFIG_FILE_NAME}

#echo "CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF ${BACKUP_STORE_DAYS} DAYS;" >> ${PATH_BACKUP_SCRIPTS}/config.rman
#echo "CONFIGURE COMPRESSION ALGORITHM 'MEDIUM';" >> ${PATH_BACKUP_SCRIPTS}/config.rman
#echo "CONFIGURE DEVICE TYPE 'DISK' PARALLELISM 8 BACKUP TYPE TO COMPRESSED BACKUPSET;" >> ${PATH_BACKUP_SCRIPTS}/config.rman

echo "created: ${RMAN_CONFIG_FILE_NAME}"

echo -n "Config rman ... "
rman target / @${RMAN_CONFIG_FILE_NAME} > ${LOGOUT}/config_rman_${date2}.log       

echo "List parameters from rman:  "
echo "show all;" > ${PATH_TO_TMP}/show_all.rman
rman target / @${PATH_TO_TMP}/show_all.rman > ${LOGOUT}/show_rman_${date2}.log       
echo "OK"
echo "-----------------------------"
cat ${LOGOUT}/show_rman_${date2}.log | grep -v default
echo "-----------------------------"

# copy files

SCP_FILE_NAME="${PATH_TO_FILES}/copy_backup.sh"
echo "scp -p ${PATH_TO_BACKUP}/* oracle@${REMOTE_HOST}:${REMOTE_HOST_DIR} " > ${SCP_FILE_NAME}
status=$?
if [ $status -ne 0 ]; then
    echo "error creating file: ${SCP_FILE_NAME}"
    exit $status
fi

chmod u+x ${SCP_FILE_NAME}
echo "created: ${SCP_FILE_NAME}"

echo "OK "

