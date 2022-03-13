#!/bin/sh

# Import cluster options from vars.sh
source vars.sh


#########################
#  Check Postgres Size  #
#########################

# Check if the postgres volume needs to be resized
# Get the size of the postgres volume in GB
vol_info=($(fly volumes list -a ${FLY_APP_NAME}-db | grep GB))
vol_size_gb=$(echo ${vol_info[3]} | awk '{ print substr( $0, 1, length($0)-2 ) }')

# Get the size of the database in bytes
db_size_bytes=$(curl -s "https://api.fly.io/prometheus/${FLY_ORG}/api/v1/query?" \
      --data-urlencode 'query=pg_database_size_bytes{app="${FLY_APP_NAME}-db"}'\
      --data-urlencode "time=$(date +%s)" \
      -H "Authorization: Bearer $(fly auth token)" \
      | jq '.data.result[] | select(.metric.datname == "postgres") | .value[1]')

# Then convert the database size to GB
db_size_gb=$(awk 'BEGIN { print "$db_size_bytes/1073741824" }';)

# Check if the database size is greater than 89% of the total volume size
if [ -z $(awk -v db_s=$db_size_gb -v vol_s=$vol_size_gb \
     'BEGIN { if (db_s/vol_s < 0.9) print "less" }') ]; then
    # If the database size is >= 90% of the total volume size
    # increase the size of the volume
    fly volumes create pg_data \
       --size $(awk -v vol_size=$vol_size_gb 'BEGIN { print vol_size + 1}') \
       --region ${FLY_APP_REGION} \
       --app ${FLY_APP_NAME}-db

       # Scale the postgres cluster to 2 instances temporarily
       fly scale count 2 --app ${FLY_APP_NAME}-db

       # Wait for the second instance finish syncing and adopt the "replica" status
      while [ -z "$(fly status --app ${FLY_APP_NAME}-db | grep replica)" ]
      do
        sleep 15
      done

      # Delete the old smaller volume
      fly volumes delete -y ${vol_info[0]}

      # Scale the postgres cluster back to 1 instance
      fly scale count 1 --app ${FLY_APP_NAME}-db

      # Wait for the new instance to adopt the "leader" status
      while [ -z "$(fly status --app ${FLY_APP_NAME}-db | grep leader)" ]
      do
        sleep 15
      done

fi

#########################
#  Clean up S3 Uploads  #
#########################

# Create rclone config
cat <<EOF > rclone.conf
[s3]
type = s3
endpoint = ${S3_ENDPOINT}
access_key_id = ${S3_ACCESS_KEY}
secret_access_key = ${S3_SECRET_KEY}

EOF

# Attempt cleanup cancelled multi-part uploads
rclone --config rclone.conf cleanup s3:${S3_BUCKET_NAME}

# Clean up rclone config
rm rclone.conf
