#!/bin/bash

######################################
#
# create test data on primary
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOF
host echo "## drop user $TST_USR_NAME cascade"
drop user $TST_USR_NAME cascade;
host echo "## create test user $TST_USR_NAME/$TST_USR_PWD"
create user $TST_USR_NAME identified by $TST_USR_PWD;
host echo "## grant connect, resource to $TST_USR_NAME"
grant connect, resource to $TST_USR_NAME;
host echo "##conn $TST_USR_NAME/$TST_USR_PWD"
conn $TST_USR_NAME/$TST_USR_PWD
host echo "## create table TST_TABLE_NAME (col1 number, col2 timestamp)"
create table $TST_TABLE_NAME (col1 number, col2 timestamp);
host echo "## insert data to $TST_TABLE_NAME"
declare
begin
	for i in 0..1000 loop
		insert into $TST_TABLE_NAME values (i, sysdate);
	end loop;
	commit;
end;
/
host echo "## select count(1) from $TST_TABLE_NAME"
select count(1) from $TST_TABLE_NAME;
exit;
EOF
