#!/bin/bash

# die on non-zero return codes
set -e 

# echo on!
#set -x

# script to restore all specified database backups (*.sql.gz.e)

if [ $# -lt 1 ]
then
   echo "Script to quickly restore backup files made by mysql_s3_backup.php"
   echo
   echo "Usage: $0 file1.sql.gz.e [file2.sql.gz.e] ..."
   echo
   echo "If you want to restore all, try $0 *.sql.gz.e"
   exit 1
fi

for BACKUP_FILE in $*
do
   if [ -r $BACKUP_FILE ]
   then
       echo "File: $BACKUP_FILE"
       DATABASE_NAME=$(echo $BACKUP_FILE | sed -r 's/^(.*)\.sql\.gz\.e$/\1/')
       echo "Database: $DATABASE_NAME"

       echo "Creating database..."
       mysqladmin create $DATABASE_NAME
   
       echo "Decrypting, unzipping and exporting the backup into mysql..."
       gpg --decrypt $BACKUP_FILE | gunzip -c | mysql $DATABASE_NAME 
   else
       echo "File $BACKUP_FILE does not exist or is not readable. Exiting..."
       exit 1
   fi
done
