#!/bin/bash
export PGPASSWORD="P05tgre5!."
HOSTNAME=localhost
USERNAME=postgres
FINAL_BACKUP_DIR=./
ENABLE_PLAIN_BACKUPS=yes
ENABLE_CUSTOM_BACKUPS=yes
DAYS_TO_KEEP=7
FULL_BACKUP_QUERY="select datname from pg_database where not datistemplate and datallowconn $EXCLUDE_SCHEMA_ONLY_CLAUSE order by datname;"
DATE=`date +"%Y-%m-%d_%H:%M:%S"`


echo -e "\n\nPerforming full backups"
	echo -e "--------------------------------------------\n"

	for DATABASE in `psql -h "$HOSTNAME" -U "$USERNAME" -At -c "$FULL_BACKUP_QUERY" postgres`
	do
		if [ $ENABLE_PLAIN_BACKUPS = "yes" ]
		then
			echo "Plain backup of $DATABASE"
	 
			set -o pipefail
			if ! pg_dump -Fp -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" | gzip > $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress; then
				echo "[!!ERROR!!] Failed to produce plain backup database $DATABASE" 1>&2
			else
				mv $FINAL_BACKUP_DIR"$DATABASE".sql.gz.in_progress $FINAL_BACKUP_DIR"${DATE}_${DATABASE}".sql.gz
			fi
			set +o pipefail
                        
		fi

		if [ $ENABLE_CUSTOM_BACKUPS = "yes" ]
		then
			echo "Custom backup of $DATABASE"
	
			if ! pg_dump -Fc -h "$HOSTNAME" -U "$USERNAME" "$DATABASE" -f $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress; then
				echo "[!!ERROR!!] Failed to produce custom backup database $DATABASE"
			else
				mv $FINAL_BACKUP_DIR"$DATABASE".custom.in_progress $FINAL_BACKUP_DIR"${DATE}_${DATABASE}".custom
			fi
		fi

	done

	echo -e "\nAll database backups complete!"
	
# Delete daily backups 7 days old or more
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*.custom" -exec rm -rf '{}' ';'
find $BACKUP_DIR -maxdepth 1 -mtime +$DAYS_TO_KEEP -name "*.sql.gz" -exec rm -rf '{}' ';'