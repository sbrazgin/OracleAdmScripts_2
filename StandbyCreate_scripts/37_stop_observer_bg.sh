#!/bin/bash

######################################
#
# stop observer
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

echo "find pid dgmgrl";
ps -ef|grep -i dgmgrl|grep -v grep;
echo "kill dgmgrl process";
`ps -ef|grep -i dgmgrl|grep -v grep|awk '{print "kill -9 " $2}'`;
echo "check existing of dgmgrl process";
ps -ef|grep -i dgmgrl|grep -v grep;

