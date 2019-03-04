#!/bin/bash

######################################
#
# start observer in background
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

read -p "enter sys password for primary db: " SYS_PWD;

if [ $SYS_PWD = "NULL" ]; then
        echo "AHTUNG! sys password is null";
        echo "password : $SYS_PWD";
        echo "exit ...";
	exit;
fi

if [ ! -f $OBSERVER_START_SCRIPT_NAME ]; then
	echo "AHTUNG! observer start script don't exist: $OBSERVER_START_SCRIPT_NAME";
	echo "exit...";
	exit;
fi

echo "Log file : $OBSERVER_START_LOG";

echo                                                                                    >> $OBSERVER_START_LOG
echo "******************************************************************************"   >> $OBSERVER_START_LOG
echo "* BEGIN START OBSERVER IN BACKGROUND"                                             >> $OBSERVER_START_LOG 
echo "* PRIMARY=$PRIMARY_UNIQ_DB_NAME HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"  >> $OBSERVER_START_LOG
echo "******************************************************************************"   >> $OBSERVER_START_LOG
echo                                                                                    >> $OBSERVER_START_LOG

echo "### dgmgrl: stop observer"                                           >> $OBSERVER_START_LOG;
$ORACLE_HOME/bin/dgmgrl sys/$SYS_PWD@$PRIMARY_UNIQ_DB_NAME "stop observer" >> $OBSERVER_START_LOG 2>&1;
echo                                                                       >> $OBSERVER_START_LOG
echo "### start observer in background"                                    >> $OBSERVER_START_LOG;
echo "### dgmgrl: start observer"                                          >> $OBSERVER_START_LOG;
nohup $ORACLE_HOME/bin/dgmgrl sys/$SYS_PWD@$PRIMARY_UNIQ_DB_NAME "start observer file=observer_cofig.dat" >> $OBSERVER_START_LOG 2>&1 &
sleep 10; # for start observer

echo >> $OBSERVER_START_LOG
echo "******************************************************************************"   >> $OBSERVER_START_LOG
echo "* END START OBSERVER IN BACKGROUND"                                               >> $OBSERVER_START_LOG
echo "* PRIMARY=$PRIMARY_UNIQ_DB_NAME HOSTNAME=`hostname` `date +'%d.%m.%y %H:%M:%S'`"  >> $OBSERVER_START_LOG
echo "******************************************************************************"   >> $OBSERVER_START_LOG
echo >> $OBSERVER_START_LOG

