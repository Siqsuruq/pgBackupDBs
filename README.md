# pgBackupDBs
Simple bash script to backup Postgres Databases
1. Copy pg_backup.sh to /root/backup/dbs/
2. chmod a+x /root/backup/dbs/pg_backup.sh
3. Create crontab job, as root user
	
	crontab -u root -e
	
--------------------------------------------------------------------------------------	
    the first 0 specifies the minute, use * for every minute.
    the second 0 specifies the hour, use * for every hour.
    the third flag * specifies the day of month, every day if week day not specified.
    the forth flag * says every month.
    the fifth flag (third 0) specifies the week day. From 0 to 6 mean Sunday to Saturday.

4. Run echo "hello world!" command everyday at 16:30, add this line:

	00 23 * * * /root/backup/dbs/pg_backup.sh
	
5. Confirm new job

	crontab -u root -l
	
	
	
### RESTORE .custom ###
If your database already exists, you can restore it with the following command:

	pg_restore -U postgres -Ft -d DB_NAME < DB_NAME.custom

If your database does not exist, run first and then you can restore it with the following command:

	createdb -U postgres -W DB_NAME
	pg_restore -U postgres -Fc -d DB_NAME < DB_NAME.custom




### RESTORE .sql.gz ###
If your database already exists, you can restore it with the following command:

	gunzip -c DB_NAME.sql.gz | psql -h localhost -U postgres -d DB_NAME 

If your database does not exist, run first and then you can restore it with the following command:

	createdb -U postgres -W DB_NAME
	gunzip -c DB_NAME.sql.gz | psql -h localhost -U postgres -d DB_NAME 