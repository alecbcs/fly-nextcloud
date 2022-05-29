# fly-nextcloud
A Nextcloud Deployment &amp; Management System for Fly.io

## Table of Contents

- [Introduction](#introduction)
- [Cluster Pricing](#cluster-pricing)
- [Getting Started](#getting-started)
  - [Making an Account on Fly.io](#making-an-account-on-fly-io)
  - [Create a S3 Storage Bucket](#create-a-s3-storage-bucket)
  - [Naming Your Nextcloud Cluster](#naming-your-nextcloud-cluster)
  - [Deploying Nextcloud](#deploying-nextcloud)
    - [GitHub Workflow (Recommended)](#github-workflow-recommended)
    - [Manual](#manual)
- [Nextcloud Suggestions](#nextcloud-suggestions)
- [Maintenance Tasks](#maintenance-tasks)
- [License](#license)

## Introduction
Similar to a 1-click app from DigitalOcean or Linode this project aims to provide a simple way to install a [Nextcloud](https://github.com/nextcloud) cluster on [Fly.io](https://fly.io) using an S3 bucket as primary storage. The idea is that you should be able to fork this repository, add your own credentials as repository secrets, and then start a GitHub Action to build your Nextcloud cluster.

This project aims to tackle the task of periodically updating and maintaining your Nextcloud cluster through the use of GitHub actions. Unlike traditional 1-click apps, a maintenance job will spin up daily to check the size of your Postgres database and dynamically resize the supporting Fly volume if you are running out of space. Additionally, the (re)deployment action will run once a week to check for updates and apply them to your cluster.

## Cluster Pricing
#### Free Allowances
Checkout the details of Fly's free resources [here](https://fly.io/docs/about/pricing/#free-allowances).

#### Fly.io Virtual Machines
Running this workflow will generate a Nextcloud cluster by spinning up the following virtual machines on fly,

|            |    CPU    |   RAM   |  Price  |
|------------|-----------|---------|---------|
| Postgres   | 1 shared  | 256MB   | $1.94   |
| Redis      | 1 shared  | 256MB   | $1.94   |
| Nextcloud  | 1 shared  |   1GB   | $5.70   |

Total Cost: `$9.58/Month`

Total Cost (with Free Allowences): `$3.76/Month`

#### S3 Storage Providers
To avoid any possible conflicts of interest or sense of bias, I won't recommend a specific cloud storage provider for you to use. I've listed a couple of possible options below that I've used in the past, but you can use any S3 compatible storage system.

|                                                               |                Storage              |      Egress     |  Monthly Minimum  |
|---------------------------------------------------------------|-------------------------------------|-----------------|-------------------|
| [Backblaze](https://www.backblaze.com/b2/cloud-storage.html)  | $0.005 GB/Month ($5.00/TB/Month)    | $0.01 GB/Month  | $0.00             |
| [Cloudflare](https://www.cloudflare.com/r2-storage/)          | $0.015 GB/Month ($15.00/TB/Month)   | $0.00 GB/Month  | $0.00             |
| [DigitalOcean](https://www.digitalocean.com/products/spaces)  | $0.020 GB/Month ($20.00/TB/Month)   | $0.01 GB/Month  | $5.00             |
| [Linode](https://www.linode.com/products/object-storage/)     | $0.020 GB/Month ($20.00/TB/Month)   | $0.01 GB/Month  | $5.00             |
###### * This pricing table does not include API usage fees.
###### ** Wasabi S3 Storage is not listed since they force customers to store data all data for a minimum of 90 days.

## Getting Started
### Making an Account on Fly.io
If you haven't already, you'll need to sign up for Fly and install the `flyctl` application by heading over to [fly.io](https://fly.io/docs/hands-on/start/). After you've completed Step 3 you may come back to this guide. To see your `FLY_API_TOKEN` run the following command and save the output for later.

```
flyctl auth token
```

### Create a S3 Storage Bucket
Create an S3 bucket and key on your chosen cloud provider then save the `ACCESS_KEY_ID` and `SECRET_KEY` of your newly created key for later.

### Naming Your Nextcloud Cluster
Before you can deploy your Nextcloud cluster we'll need to give it a name and check if that name is available on Fly. Unless you've got a custom domain, this name is how you'll access your Nextcloud cluster from the web. (`YOURNAME.fly.dev`)

### Picking a `FLY_APP_REGION`
Before you deploy your Nextcloud cluster we'll also need to decide which fly data center to launch it in. To explore the available fly regions run,
```
flyctl platform regions
```
remember the three letter acronym of the region closest to you.

To check if your name is available run,
```
host YOURNAME.fly.dev
```

and if you get back a response that looks like,
```
Host YOURNAME.fly.dev not found: 3(NXDOMAIN)
```

that means your chosen name is available.

### Deploying Nextcloud
#### GitHub Workflow (Recommended)
1. Fork this repository (click fork in the top right)
2. Go to your new repository's settings >> secrets >> action's secrets
3. Create new secrets for each of the following,
   ```
   FLY_API_TOKEN
   FLY_ORG
   FLY_APP_NAME
   FLY_APP_REGION
   FLY_DB_PASSWORD
   FLY_REDIS_PASSWORD
   S3_BUCKET_NAME
   S3_ENDPOINT
   S3_ACCESS_KEY
   S3_SECRET_KEY
   ```
4. Now go to your repositories "Actions" tab. You should see two actions, (re)deploy & maintenance.
5. Click on (re)deploy & enable the workflow for your fork.
6. Now manually run your workflow by clicking "Run Workflow" on the right of the screen. Your workflow should now begin and automatically deploy your Nextcloud cluster.
7. To automatically resize your postgres DB when needed, go back to the "Actions" tab and this time enable the "Maintenance" workflow.
8. Once your deployment workflow is done you should be good to login to your new Nextcloud instance at `YOURNAME.fly.dev`.

#### Manual
1. Clone this repository
2. Open vars.sh and add your custom values to,
   ```
   export FLY_ORG=
   export FLY_APP_NAME=
   export FLY_APP_REGION=
   export FLY_DB_PASSWORD=
   export FLY_REDIS_PASSWORD=
   export S3_BUCkET_NAME=
   export S3_ENDPOINT=
   export S3_ACCESS_KEY=
   export S3_SECRET_KEY=
   ```
3. Run `chmod a+x ./deploy.sh`
4. Run `./deploy.sh`
5. Run `flyctl open -a YOUR_FLY_APP_NAME`

## Nextcloud Suggestions
Here are a couple of my personal suggestions for your new Nextcloud instance.

If you've never used Fly's ssh functionality before you should first type,
```
flyctl ssh issue
```
on your local computer.

Then after logging into your Nextcloud web interface for the first time, ssh into your cluster by running,
```
flyctl ssh console -a YOUR_NAME
```

#### Setup OCC Alias
```
alias occ='sudo -u www-data PHP_MEMORY_LIMIT=512M php /var/www/html/occ'
```

#### Limit Tashbin Size to 10GB
```
occ trashbin:size 10GB
```

#### Improve Image Thumbnail Generation
```
occ config:app:set previewgenerator squareSizes --value="32 256"
occ config:app:set previewgenerator widthSizes  --value="256 384"
occ config:app:set previewgenerator heightSizes --value="256"
occ config:system:set preview_max_x --value 2048
occ config:system:set preview_max_y --value 2048
occ config:system:set jpeg_quality --value 60
occ config:app:set preview jpeg_quality --value="60"
```

### Generate Image Thumbnails When System Idle Instead of On Demand
Click on the circle at the very top right of the web interface > Click on Apps 
> Search (Magnifying Glass) "Preview Generator" > Click on "Download and Enable"
> Enter Your Password if Needed > Done!

#### Fix Nextcloud Desktop & Mobile Login Auth Errors
```
occ config:system:set overwritehost --value="YOURNAME.fly.dev"
occ config:system:set overwriteprotocol --value="https"
```

#### Increase Log Level to 3 (Errors Only) to Improve Page Load Speed
```
occ config:system:set loglevel --value 3
```

#### Disable Rich Workspaces to Reduce Interface Clutter
```
occ config:app:set text workspace_available --value 0
```

#### Exit
To leave your ssh session type,
```
exit
```

## Maintenance Tasks
### Automatically Scaling Postgres's Volume

Over time, you may need to increase the size of the volume attached to your Postgres instance as your database grows.

If you deployed your Nextcloud cluster using the GitHub Workflow method, you shouldn't need to worry about this, as we automatically run a workflow every day to check if your database is within 90% of your volume size. If your database is greater than 90% of your volume size, the workflow will dynamically increase the size of your volume.

If you deployed your Nextcloud cluster manually, you should set up a way to periodically run the `maintenance.sh` script to dynamically resize the volume attached to your Postgres instance.

### Cleaning up Incomplete Uploads from S3
One of the long-standing complaints in the community about using a Nextcloud cluster with an S3 backend is that Nextcloud doesn't cleanup failed uploads automatically. This means that your S3 bucket continues to grow in size with inaccessible failed uploads even if the size of your Nextcloud files stays the same. To prevent this from happening, this Workflow as well as maintenance.sh scrape for incomplete uploads in your S3 bucket and delete those older than 1 week.

## Disclaimer

Do not enable Nextcloud server-side encryption with this setup as it will lead to data corruption. See nextcloud/server#22077 for more details.

## License

Copyright 2022 Alec Scott hi@alecbcs.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
