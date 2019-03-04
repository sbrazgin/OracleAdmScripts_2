#!/bin/bash

######################################
#
# insert data for test in primary db
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" <<EOF
host echo "## conn $TST_USR_NAME/$TST_USR_PWD"
conn $TST_USR_NAME/$TST_USR_PWD
host echo "## drop table $TST_TABLE_NAME;"
drop table $TST_TABLE_NAME;
host echo "## create table $TST_TABLE_NAME (col1 number, col2 number, col3 timestamp)"
create table $TST_TABLE_NAME (col1 number, col2 number, col3 timestamp);
set serveroutput on;
host echo "## insert into $TST_TABLE_NAME values (i, j, sysdate) in loop"
declare
 i 	number; 
 j 	number;
 cnt	number;
begin
	for i in 1..40 loop
		for j in 1..10000 loop
			insert into $TST_TABLE_NAME values (i, j, sysdate);
		end loop;

		commit;
		select count(1) into cnt from $TST_TABLE_NAME;
		dbms_output.put_line('i,count: '||i||','||cnt);


	end loop;
	commit;
end;
/
exit;
EOF
