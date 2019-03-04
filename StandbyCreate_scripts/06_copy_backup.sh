#!/bin/bash

######################################
#
# backup copy between hosts
#
######################################

if [ ! $1 ] || [ ! $2 ] || [ ! $3 ]; then
	echo "Usage: $0 hotbackup_path_from IP_TO hotbackup_path_to";
	echo "exit...";
	exit;
fi

export HOTBACKUP_PATH_FROM=$1;
export IP_TO=$2
export HOTBACKUP_PATH_TO=$3;

echo 

if [ ! -d $HOTBACKUP_PATH_FROM ]; then
	echo "HOTBACKUP_PATH_FROM don't exist: $HOTBACKUP_PATH_FROM";
	echo "exit...";
	exit;
else
	echo "HOTBACKUP_PATH_FROM exist: $HOTBACKUP_PATH_FROM";
fi

echo
echo "create directory $IP_TO:$HOTBACKUP_PATH_TO";
ssh $IP_TO "mkdir -p $HOTBACKUP_PATH_TO";

echo
echo "AHTUNG!!!: check $IP_TO:$HOTBACKUP_PATH_TO";
echo "if not exist, create...";
read -p "Press any key to continue..."

echo
echo

# delete if exist endind / from paths
export HOTBACKUP_PATH_FROM=`echo $HOTBACKUP_PATH_FROM|sed -e 's/\/$//g'`;
export HOTBACKUP_PATH_TO=`echo $HOTBACKUP_PATH_TO|sed -e 's/\/$//g'`;

export IFS=$'\n';
export tmp_file_name=/tmp/tmp_file_`date +'%d%m%y_%H%M%S'`;
export tmp_file_name_2=/tmp/tmp_file_`date +'%d%m%y_%H%M%S'`_2.sh;
lines_count=0;
ls $HOTBACKUP_PATH_FROM/|awk '{print "scp -p -r $HOTBACKUP_PATH_FROM/"$1" ""'$IP_TO'"":""'$HOTBACKUP_PATH_TO'"" &"}' > $tmp_file_name
for i in $(cat $tmp_file_name); do  
	((lines_count=lines_count+1));
	if [ $lines_count = 10 ]; then
		lines_count=1;
		echo "sleep 2" >> $tmp_file_name_2;
	fi
	#echo $lines_count $i;
	echo $i >> $tmp_file_name_2;

done;

echo "remove $tmp_file_name";
rm $tmp_file_name;

echo
echo "contents of $tmp_file_name_2";
cat $tmp_file_name_2;

echo
echo "execute $tmp_file_name_2";
chmod u+x $tmp_file_name_2
$tmp_file_name_2;

echo
#-->echo "remove $tmp_file_name_2";
#-->rm $tmp_file_name_2;
