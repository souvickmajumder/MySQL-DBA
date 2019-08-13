#!/bin/bash
# This script uses mysqldump to backup all the databases except 'bkp' and 'test' databases.
# This script also uses mysqldump to backup all the tables in the databases.
# The script creates a backup destination folder for each day, the folder name is like 'yyyymmdd',
# The MySQLDump output will be compressed using bzip2
# The script deletes any files and sub-folders older than defined days in the backup folder
# The cronjob line is like this: 10 2 * * * /root/mysql_bkp.sh >/var/log/hhc-mysql-bkp.log 2>&1
. /etc/profile
suffix=$1
dest=/backup-hhc/$1
cmd1=$(which mysql)
hostname=$(hostname --short)
input_file=/backup-hhc/temp.sql
if [ $2 = 'ALL' ]
then
databases=$(echo 'show databases;' | ${cmd1} --login-path=local | grep -i refman)

for d in ${databases[@]}
  do
     if [[ $d != 'information_schema' && $d != 'performance_schema' && $d != 'test'  && $d != 'mysql' && $d != 'refman_hcprdtmplt_1024480_20170822' ]]
     then

     path="${dest}/${hostname}"
     mkdir -p ${path}

     timestamp=`date +%Y%b%d-%T`
	while read line; do 
    	echo -e  "$line" >> $path/$d.csv
	${cmd1} $d -e "$line" | sed 's/\t/,/g' >>$path/$d.csv
	echo "" >> $path/$d.csv
	done < $input_file

     fi
  done
else
while read line; do
        echo -e  "$line" >> $path/$dest.csv
        ${cmd1} $2 -e "$line" | sed 's/\t/,/g' >>$dest.csv
        echo "" >> $path/$dest.csv
        done < $input_file
fi
