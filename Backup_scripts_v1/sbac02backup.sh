#!/bin/bash

########################################################################
# Sergey Brazgin   09.2014   sbrazgin@gmail.com
# 
# 1) create backup
# 2) call db_info.sh
#
########################################################################

cd /home/oracle/scripts
. ./00_all_vars.sh

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

[ -d $LOGOUT ] || mkdir -p $LOGOUT
[ -d $PATH_TO_BACKUP ] || mkdir -p $PATH_TO_BACKUP


#---- ora env 
. ${PATH_TO_FILES}/oraenv.sh


#---- case
case $1 in

hourly)

rman target / @sbacHOURLY.rman > $LOGOUT/HOURLY_${date2}.log       

;;
daily)

rman target / @sbacDAILY.rman > $LOGOUT/DAILY_${date2}.log	

;;
full)

rman target / @sbacFULL.rman  > $LOGOUT/FULL_${date2}.log	
#rman target / @sbacFULL.rman using "FULL_DB_$date1" "FULL_ARC_$date1" > $LOGOUT/FULL_${date2}.log	

;;
*)

echo -e "\n\tUsage $0 (hourly|daily|full)\n
	hourly	make a hourly backup of archivelogs
	daily	make a daily incremental level 1 backup
	full	make a full backup (level 0)\n"
exit ${GEN_ERR}
;;
esac

cd /home/oracle/scripts
./sbac04db_info.sh

