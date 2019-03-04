#!/bin/bash

########################################################################
# author: Sergey Brazgin     09.2014     mail:   sbrazgin@gmail.com
########################################################################

cd /home/oracle/scripts
source 00_all_vars.sh

export PATH_TO_LOGS=logs
export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
export date=`date +%Y%m%d%H%M%S`
export date1=`date +%Y_%m_%d`
export date2=`date +%H_%M_%S`
GEN_ERR=1  # something went wrong in the script

#---- dirs
export PATH_TO_FILES="${MKDIR_BACKUP2_PATH}"
echo "PATH_TO_FILES=${PATH_TO_FILES}"

export PATH_TO_BACKUP="${MKDIR_BACKUP2_PATH}/backup"
echo "PATH_TO_BACKUP=${PATH_TO_BACKUP}"

export PATH_TO_LOGS="${MKDIR_BACKUP2_PATH}/logs"
echo "PATH_TO_LOGS=${PATH_TO_LOGS}"

export LOGOUT=$PATH_TO_LOGS/$date1
echo "LOGOUT=${LOGOUT}"

export PATH_TO_TMP=${MKDIR_BACKUP2_PATH}/temp
echo "PATH_TO_TMP=${PATH_TO_TMP}"

[ -d $LOGOUT ] || mkdir -p $LOGOUT
[ -d $PATH_TO_BACKUP ] || mkdir -p $PATH_TO_BACKUP
[ -d $PATH_TO_TMP ] || mkdir -p $PATH_TO_TMP


#---- ora env 
. ${PATH_TO_FILES}/oraenv.sh



#----------- create db_info.txt
FILE_SQL_1="${PATH_TO_TMP}/db_info1.sql"
FILE_OUT_1="${PATH_TO_BACKUP}/db_info.txt"

echo "select * from global_name;" > ${FILE_SQL_1}
echo "select dbid from v\$database;" >> ${FILE_SQL_1} 

output=`sqlplus -s / as sysdba <<EOF
           spool $FILE_OUT_1
           @${FILE_SQL_1};
           exit;
EOF
`
if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi



#----------- create rman_backup_info.txt
FILE_RMAN_1="${PATH_TO_TMP}/db_info2.rman"
FILE_OUT_1="${PATH_TO_BACKUP}/rman_backup_info.txt"

export NLS_DATE_FORMAT='DD-MON-YY HH24:MI:SS'
echo " list backup; " > ${FILE_RMAN_1}
rman target / cmdfile ${FILE_RMAN_1} log ${FILE_OUT_1}

if [ $? -ne 0 ]
then
  echo "Running rman FAILED"
  exit ${GEN_ERR}
fi



#------------  get dbid value
FILE_SQL_1="${PATH_TO_TMP}/db_info3.sql"
FILE_OUT_1="${PATH_TO_TMP}/db_info3.txt"

LOGOUT=backup/db_info2.txt

echo "set verify off" > ${FILE_SQL_1}
echo "set heading off " >> ${FILE_SQL_1}
echo "set echo off " >> ${FILE_SQL_1}
echo "set head off" >> ${FILE_SQL_1}
echo "set verify off" >> ${FILE_SQL_1}
echo "set feedback off" >> ${FILE_SQL_1}
echo "select dbid from v\$database; " >> ${FILE_SQL_1}


output=`sqlplus -s -l / as sysdba <<EOF
      spool ${FILE_OUT_1}
      @${FILE_SQL_1};
      exit;
EOF
`

if [ $? -ne 0 ]
then
  echo "Running sqlplus FAILED"
  exit ${GEN_ERR}
fi

if [ -z "${output}" ] # check if  empty
then
  echo "No Database ID were found"
  exit ${GEN_ERR}
fi

#remove carriage return and newline from a variable
output=$(echo $output | sed -e 's/\r//g')

echo "output = $output"

# create oraenv
FILE_OUT_1="${PATH_TO_BACKUP}/oraenv_db.sh"

echo "export ORACLE_SID=${ORACLE_SID}" > ${FILE_OUT_1}
echo "export ORACLE_DBID=${output}" >> ${FILE_OUT_1}

