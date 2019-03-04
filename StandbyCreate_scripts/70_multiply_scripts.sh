#!/bin/bash

######################################
#
# copy scripts between hosts
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

if [ $LOCAL_HOST_NAME == $PRIMARY_HOST ]; then
        export SCP_HOST_NAME_1=$STANDBY_HOST;
        export SCP_HOST_NAME_2=$OBSERVER_HOST;

elif [ $LOCAL_HOST_NAME == $STANDBY_HOST ]; then
        export SCP_HOST_NAME_1=$PRIMARY_HOST;
        export SCP_HOST_NAME_2=$OBSERVER_HOST;

elif [ $LOCAL_HOST_NAME == $OBSERVER_HOST ]; then
        export SCP_HOST_NAME_1=$PRIMARY_HOST;
        export SCP_HOST_NAME_2=$STANDBY_HOST;

fi

echo;
echo "##########################";
echo "copy to $SCP_HOST_NAME_1";
echo "##########################";
echo;
scp ./* $SCP_HOST_NAME_1:`pwd`;

echo;
echo "##########################";
echo "copy to $SCP_HOST_NAME_2";
echo "##########################";
echo;
scp ./* $SCP_HOST_NAME_2:`pwd`;
