#!/bin/bash

######################################
#
# create trigger for OAS service
#
######################################

source 00_all_vars.sh

echo;
show_hosts_db_names;
echo;

export CONTINUE_RUN=N

read -p "Now will create service trigger on database $ORACLE_SID, continue (Y/N) ? : " CONTINUE_RUN;

if [ $CONTINUE_RUN = "N" ]; then
	echo "OK! exit...";
	exit;
elif [ ! $CONTINUE_RUN = "Y" ]; then
	echo "Check your answer, need Y or N";
	echo "Exit...";
	exit;
fi

$ORACLE_HOME/bin/sqlplus -S "/ as sysdba" << EOF
exec DBMS_SERVICE.STOP_SERVICE('OAS'); 
exec DBMS_SERVICE.DELETE_SERVICE('OAS');
exec DBMS_SERVICE.CREATE_SERVICE(service_name => 'OAS',network_name => 'OAS');
exec DBMS_SERVICE.START_SERVICE('OAS');

create or replace trigger manage_service 
	after DB_ROLE_CHANGE on database
declare 
	db_role 		varchar(30); 
	service_name		varchar2(64)  := 'OAS';
	service_name_active	varchar2(64);
begin 
	select database_role into db_role from v\$database; 

	begin  
		select name into service_name_active from v\$active_services where name=service_name;
	exception
		when NO_DATA_FOUND then
		service_name_active := 'NOT_FOUND';
	end;


	if db_role = 'PRIMARY' then 

    	   if service_name_active != service_name then
	    DBMS_SERVICE.START_SERVICE(service_name);
	   end if;
 
	else 
		DBMS_SERVICE.STOP_SERVICE(service_name); 
	end if; 
end;
/


create or replace trigger manage_service_onstart
	after startup on database
declare 
	db_role 		varchar(30); 
	service_name		varchar2(64)  := 'OAS';
	service_name_active	varchar2(64);
begin 
	select database_role into db_role from v\$database; 

	begin  
		select name into service_name_active from v\$active_services where name=service_name;
	exception
		when NO_DATA_FOUND then
		service_name_active := 'NOT_FOUND';
	end;
	

	if db_role = 'PRIMARY' then 

	   if service_name_active != service_name then
	    	DBMS_SERVICE.START_SERVICE(service_name);
	   end if;

	else 
		DBMS_SERVICE.STOP_SERVICE(service_name); 
	end if; 
end;
/

-- show trigger status
set linesize 150
set pagesize 1000
col OWNER format a5
col NAME format a24
col TYPE format a14
col EVENT format a10
col WHEN_CLAUSE format a10
col ACTION_TYPE format a11
col STATUS format a10
select OWNER, TRIGGER_NAME "NAME", TRIGGER_TYPE "TYPE", TRIGGERING_EVENT "EVENT", ACTION_TYPE, STATUS from dba_triggers where trigger_name like 'MANAGE_SERVICE%';

exit;
EOF

$ORACLE_HOME/bin/lsnrctl service|grep -i oas
