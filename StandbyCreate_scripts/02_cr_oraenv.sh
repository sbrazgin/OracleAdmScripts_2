#!/bin/bash

######################################
#
# create env file - configs
#
######################################

source 00_all_vars.sh

ENV_FILE="/home/oracle/.oracle.${ORACLE_SID}.env"

rm -rf ${ENV_FILE}

cat <<EOT >> ${ENV_FILE}
export PATH=/usr/local/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/usr/bin/X12:/sbin:/bin:.
export ORACLE_SID=${ORACLE_SID}
export ORAENV_ASK=NO

. oraenv

export PATH=\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:$PATH
export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
export NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS'
export NLS_TIMESTAMP_FORMAT='DD-MM-YYYY HH24:MI:SSXFF'
export NLS_TIMESTAMP_TZ_FORMAT='DD-MM-YYYY HH24:MI:SSXFF TZR:TZD'

shopt -s histappend
shopt -s histverify
HISTSIZE=3000
HISTCONTROL=ignoreboth
alias hg='history|grep -i -e'
alias psg='ps -ef|grep -i -e'
EOT


chmod u+x ${ENV_FILE}


cat <<EOT >> /home/oracle/.bash_profile
. ${ENV_FILE}
EOT

