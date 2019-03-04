#!/bin/bash


########################################################################
#
# switch on archivelog, force logging, flashback, and create spfile
#
########################################################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

export CONTINUE_RUN=N

read -p "Now database $ORACLE_SID will shutdown, continue (Y/N) ? : " CONTINUE_RUN;

if [ $CONTINUE_RUN = "N" ]; then
	echo "OK! exit...";
	exit;
elif [ ! $CONTINUE_RUN = "Y" ]; then
	echo "Check your answer, need Y or N";
	echo "Exit...";
	exit;
fi


$ORACLE_HOME/bin/sqlplus "/ as sysdba" << EOF
host echo 'exec: shutdown immediate'; exit

shutdown immediate;

host echo 'exec: startup mount'; exit

startup mount;
host echo 'exec: alter database archivelog'; 
alter database archivelog;

host echo 'exec: alter database force logging'; exit
alter database force logging;

host echo 'exec: alter database flashback on'; exit
alter database flashback on;

set linesize 150
col LOG_MODE format a20
col PROTECTION_MODE format a20
col PROTECTION_LEVEL format a20
col FLASHBACK_ON format a20
col FORCE_LOGGING format a20
host echo 'exec: select LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database'; exit
select LOG_MODE, FLASHBACK_ON, FORCE_LOGGING, PROTECTION_MODE, PROTECTION_LEVEL from v\$database;

host echo 'exec: alter database open'; exit
alter database open;

host echo 'exec: select open_mode from v\$database'; exit
select open_mode from v\$database;
exit;
EOF

#--> непонятно зачем - база и так поднята с spfile ??????
#--> host echo 'exec: create spfile from pfile'; exit
#--> create spfile from pfile;
