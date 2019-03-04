#!/bin/bash

######################################
#
# create standby redo on standby db
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
set linesize 150
set serveroutput on;
declare
 standby_logs_exists		number 		:= 0;
 max_groups 			number 		:= 0;
 count_groups 			number 		:= 0;
 curr_group 			number 		:= 0;
 max_onlinelog_size		number 		:= 0;
 standby_logfile_path 		varchar2(100) 	:= '$STANDBY_LOG_FILE_PATH';
begin
	dbms_output.put_line(CHR(13)||CHR(10)||'##############################################################################################');
	dbms_output.put_line('<=== This PL/SQL generate SQL script for add standby logfiles ===>');

	select count(group#) into standby_logs_exists from v\$standby_log;
	if standby_logs_exists>0 then
		dbms_output.put_line(CHR(13)||CHR(10));
		dbms_output.put_line('===========================================================');
		dbms_output.put_line('AHTUNG!');
		dbms_output.put_line('AHTUNG!: standby logfiles already exists!');
		dbms_output.put_line('AHTUNG!');
		dbms_output.put_line('===========================================================');
		dbms_output.put_line(CHR(13)||CHR(10));
	end if;
	

	dbms_output.put_line('recommended number of standby redo log file groups = (maximum number of logfiles for each thread + 1) * maximum number of threads');

	select max(group#) into count_groups from (select group# from v\$log);	

	select max(group#) into max_groups from (select group# from v\$log union all select group# from v\$standby_log);	
	
	select max(bytes)/1024/1024 into max_onlinelog_size from v\$log;

	dbms_output.put_line('Count.Groups = '||count_groups);
	dbms_output.put_line('Max.Group number = '||max_groups);
	dbms_output.put_line('Max.Onlinelog.Size (Mb) = '||max_onlinelog_size||CHR(13)||CHR(10));

	curr_group:=max_groups + 1;
	for ii in ( select distinct THREAD# from v\$log order by 1 ) loop 
		for i in 0..count_groups loop
			dbms_output.put_line('alter database add standby logfile thread '||ii.thread#||' group '||curr_group||' ('''||standby_logfile_path||'$ORACLE_SID'||'_standby_redo_g'||curr_group||'m1.dbf'')'||' size '||max_onlinelog_size||'M;');
			curr_group:=curr_group+1;
		end loop;
	end loop;

		dbms_output.put_line(CHR(13)||CHR(10));
		dbms_output.put_line('===========================================================');
		dbms_output.put_line('WARNING!');
		dbms_output.put_line('WARNING!: You must run this script !!!');
		dbms_output.put_line('WARNING!');
		dbms_output.put_line('===========================================================');
		dbms_output.put_line(CHR(13)||CHR(10));
	
	dbms_output.put_line(CHR(13)||CHR(10)||'Check standby log:'); 
	dbms_output.put_line('SELECT GROUP#,THREAD#,SEQUENCE#,ARCHIVED,STATUS FROM V\$STANDBY_LOG;');
	dbms_output.put_line(CHR(13)||CHR(10)||'##############################################################################################');	
end;
/
exit;
EOF
