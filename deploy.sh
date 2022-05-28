#!/bin/sh

# Import cluster options from vars.sh
source vars.sh

#################
#   Postgres    #
#################

# Check if the postgres cluster has already been deployed
if [ -z "$(fly pg list | grep ${FLY_APP_NAME}-db)" ]; then
   # If the postgres cluster has not already been deployed, deploy it
   fly pg create --name ${FLY_APP_NAME}-db \
                 --organization ${FLY_ORG} \
                 --region ${FLY_APP_REGION} \
                 --vm-size "shared-cpu-1x" \
                 --volume-size 1 \
                 --initial-cluster-size 1 \
                 --password ${FLY_DB_PASSWORD}
fi

#################
#     Redis     #
#################

# Check if the Redis app has already been deployed
if [ -z "$(fly apps list | grep '${FLY_APP_NAME}-redis')" ]; then
   # Create the redis app
   fly launch --name ${FLY_APP_NAME}-redis \
              --no-deploy \
              --org ${FLY_ORG} \
              --region ${FLY_APP_REGION}

   # Create volume for redis app
   fly volumes create redis_data \
      --size 1 \
      --region ${FLY_APP_REGION} \
      --app ${FLY_APP_NAME}-redis

    # Clean up generated fly.toml config
    rm fly.toml

fi

# Enter Redis config
cd redis

# Generate Redis config file
sed -i "s/%fly_app_name%/${FLY_APP_NAME}/g" fly.toml
sed -i "s/%fly_redis_password%/${FLY_REDIS_PASSWORD}/g" fly.toml

# Deploy Redis
fly deploy

# Leave Redis config
cd ..

# Clean up changed file
git restore redis/fly.toml

#################
#   Nextcloud   #
#################

# Check if the nextcloud app has already been deployed
if [ -z "$(fly apps list | grep ${FLY_APP_NAME}[^-])" ]; then
    # Create the nextcloud app
    fly launch --name ${FLY_APP_NAME} \
               --no-deploy \
               --org ${FLY_ORG} \
               --region ${FLY_APP_REGION}

    # Scale nextcloud memory to 1GB
    fly scale memory 1024

    # Create volume for redis app
    fly volumes create nextcloud_data \
       --size 1 \
       --region ${FLY_APP_REGION} \
       --app ${FLY_APP_NAME}

    # Clean up generated fly.toml config
    rm fly.toml
fi

 # Enter Nextcloud config
cd nextcloud

# Generate Nextcloud config file
sed -i "s/%fly_app_name%/${FLY_APP_NAME}/g" fly.toml
sed -i "s/%fly_redis_password%/${FLY_REDIS_PASSWORD}/g" fly.toml
sed -i "s/%fly_db_password%/${FLY_DB_PASSWORD}/g" fly.toml
sed -i "s/%s3_bucket_name%/${S3_BUCKET_NAME}/g" fly.toml
sed -i "s/%s3_access_key%/${S3_ACCESS_KEY}/g" fly.toml
sed -i "s/%s3_secret_key%/${S3_SECRET_KEY}/g" fly.toml
sed -i "s/%s3_endpoint%/${S3_ENDPOINT}/g" fly.toml

# Deploy Nextcloud
fly deploy

# Leave Nextcloud config
cd ..

# Clean up changed file
git restore nextcloud/fly.toml
