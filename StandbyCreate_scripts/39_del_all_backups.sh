#!/bin/bash

######################################
#
# delee all backups
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/rman target/ nocatalog <<EOF
configure snapshot controlfile name to '$ORACLE_HOME/dbs/snapshot_controlfile.f';
run {
	crosscheck backup device type disk;  
	delete noprompt backup;
	change archivelog all uncatalog;
}
list backup;
EOF

