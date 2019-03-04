#!/bin/bash

######################################
#
# create all need directories on
# primary, standby, observer hosts
#
######################################


source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

echo "#### list of dirs for create";
echo "DIRS LIST: $MKDIR_LIST";
echo;

#### create on primary
echo "#### create dirs on primary host";
mkdir -p $MKDIR_LIST;
echo;
echo "#### Test created dirs";
ls -all -d $MKDIR_LIST;
echo;

### create on standby
echo "#### create dirs on standby host";
ssh $STANDBY_HOST "mkdir -p $MKDIR_LIST";
echo;
echo "### Test created dirs";
ssh $STANDBY_HOST "ls -all -d $MKDIR_LIST";
echo;

### create on observer
#--> echo "#### create dirs on observer host";
#--> ssh $OBSERVER_HOST "mkdir -p $MKDIR_LIST_HOTBACK_HOST";
#--> echo;
#--> echo "### Test created dirs";
#--> ssh $OBSERVER_HOST "ls -all -d $MKDIR_LIST_HOTBACK_HOST";
#--> echo;

