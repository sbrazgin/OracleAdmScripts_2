#!/bin/bash 


########################################################################
# author: Sergey Brazgin    sbrazgin@gmail.com
#  create entry in crontab
########################################################################

command="nohup /home/oracle/scripts/sbac02backup.sh full >> /home/oracle/scripts/cron_full_log.out &"
job="0 21 * * 2,5 $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

command="nohup /home/oracle/scripts/sbac02backup.sh daily >> /home/oracle/scripts/cron_daily_log.out &"
job="0 21 * * 0,1,3,4,6 $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -

command="nohup /home/oracle/scripts/sbac02backup.sh hourly >> /home/oracle/scripts/cron_hour_log.out &"
job="0 0-20,22-23 * * * $command"
cat <(fgrep -i -v "$command" <(crontab -l)) <(echo "$job") | crontab -
