#! /bin/sh
# PSQL Database Backup to AWS S3

echo "Starting PSQL Database Backup..."

# create backup params
backup_name=$POSTGRES_DB'_'$(date +%d'-'%m'-'%Y).sql

# Create, compress, and encrypt the backup
PGPASSWORD=$POSTGRES_PASSWORD pg_dump -v -d $POSTGRES_DB -U $POSTGRES_USER -h $POSTGRES_HOST > $backup_name

# check backup created
if [ ! -e "$backup_name" ]; then
    echo 'Backup file not found'
    exit 1
else 
    echo 'Backup successful'  
fi

# push backup to S3
aws s3 cp $backup_name "s3://$S3_BUCKET/$S3_FOLDER/"
status=$?

# indicate if backup was successful
if [ $status -eq 0 ]; then
    echo "PSQL database backup: '$backup_name' completed to '$S3_BUCKET/$S3_FOLDER/'"

    # remove expired backups from S3
    if [ "$ROTATION_PERIOD" != "" ]; then
        aws s3 ls "$S3_BUCKET" --recursive | while read -r line;  do
            stringdate=$(echo "$line" | awk '{print $1" "$2}')
            filedate=$(date -d"$stringdate" +%s)
            olderthan=$(date -d"-$ROTATION_PERIOD days" +%s)
            if [ "$filedate" -lt "$olderthan" ]; then
                filetoremove=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^[ \t]*//')
                if [ "$filetoremove" != "" ]; then
                    aws s3 rm "s3://$S3_BUCKET/$S3_FOLDER/$filetoremove"
                fi
            fi
        done
    fi
else
    echo "PSQL database backup: '$backup_name' failed"
    exit 1
fi

# copy production dump to develop database
if [ "$S3_FOLDER" = "develop" ]; then
    S3_FOLDER="production"
    
    # get latest dump 
    dump=`aws s3 ls "s3://$S3_BUCKET/$S3_FOLDER/" --recursive | sort | tail -n 1 | awk '{print $4}' | awk -F '/' '{print $NF}'`
    # pull production dump from S3
    aws s3 cp "s3://$S3_BUCKET/$S3_FOLDER/$dump" $dump

    # drop and re-create database before restore
    echo "Dropping database $POSTGRES_DB..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -v -d postgres -U $POSTGRES_USER -h $POSTGRES_HOST -c "DROP DATABASE $POSTGRES_DB;"
    echo "Creating database $POSTGRES_DB..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -v -d postgres -U $POSTGRES_USER -h $POSTGRES_HOST -c "CREATE DATABASE $POSTGRES_DB;"
    # restore production dump to develop database
    echo "Restoring database $POSTGRES_DB from $dump..."
    PGPASSWORD=$POSTGRES_PASSWORD psql -v -d $POSTGRES_DB -U $POSTGRES_USER -h $POSTGRES_HOST < $dump
fi