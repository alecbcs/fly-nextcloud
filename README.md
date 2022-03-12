# fly-nextcloud
A Nextcloud Deployment &amp; Management System for Fly.io

## Table of Contents

- [Introduction](#introduction)
- [Pricing](#pricing)
- [Getting Started](#getting-started)
  - [Making an Account on Fly.io](#making-an-account-on-fly-io)
  - [Create a S3 Storage Bucket](#create-a-s3-storage-bucket)
  - [Naming Your Nextcloud Cluster](#naming-your-nextcloud-cluster)
  - [Deploying Nextcloud](#deploying-nextcloud)
    - [GitHub Workflow (Recommended)](#github-workflow-recommended)
    - [Manual](#manual)
- [Maintenance Tasks](#maintenance-tasks)
- [License](#license)

## Introduction


## Pricing
#### Free Allowances
Checkout the details of Fly's free resources [here](https://fly.io/docs/about/pricing/#free-allowances).

#### Fly.io Virtual Machines
|           |    CPU    |   RAM   |  Price  |
|-----------|-----------|---------|---------|
| Postgres  | 1 shared  | 256MB   | $1.94   |
| Redis     | 1 shared  | 256MB   | $1.94   |
| Nextcloud | 1 shared  | 512MB   | $3.82   |

Total Cost: `$7.70/Month`
Total Cost (with Free Allowences): `$1.88/Month`

#### S3 Storage Providers
In order to prevent the appearance of bias/possible conflicts of interest, I won't recommend a specific cloud storage provider for you to use. I've listed a couple of possible options below that I've used in the past but you can use any S3 compatible storage system.

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
If you haven't already, you'll need to sign up for Fly and install the `flyctl` application by heading over to [fly.io](https://fly.io/docs/hands-on/start/). After you've completed Step 3 you may come back to this guide.

### Create a S3 Storage Bucket
Create an S3 bucket and key on your chosen cloud provider then save the `ACCESS_KEY_ID` and `SECRET_KEY` of your newly created key for later.

### Naming Your Nextcloud Cluster
Before you can deploy your Nextcloud cluster we'll need to give it a name and check if that name is available on Fly. Unless you've got a custom domain, this name is how you'll access your Nextcloud cluster from the web. (`YOURNAME.fly.dev`)

To check if your name is available run,
```
host YOURNAME.fly.dev
```

and if you get back a response that looks like,
```
Host YOURNAME.fly.dev not found: 3(NXDOMAIN)
```

that means your name is available!

### Deploying Nextcloud
#### GitHub Workflow (Recommended)


#### Manual
1. Clone this repository
2. Open `vars.sh` and add your custom values to,
   ```
   export FLY_ORG=
   export FLY_APP_NAME=
   export FLY_APP_REGION=
   export FLY_DB_PASSWORD=
   export FLY_REDIS_PASSWORD=
   export S3_ENDPOINT=
   export S3_ACCESS_KEY=
   export S3_SECRET_KEY=
   ```
3. Run `chmod a+x ./deploy.sh`
4. Run `./deploy.sh`
5. Run `flyctl open -a YOUR_FLY_APP_NAME`

## Maintenance Tasks
### Automatically Scaling Postgres's Volume
Over time it may be nessisary to increase the size of the volume attached to your Postgres instance as your database grows.

If you deployed your Nextcloud cluster using the GitHub Workflow method you shouldn't need to worry about this as we automatically run a workflow everyday to check if your database is within 90% of your volume size. If your database is greater than 90% of your volume size the workflow will dynamically increase the size of your volume.

If your deployed your Nextcloud cluster manually you should setup a way to periodically run the `maintenance.sh` script to dynamically resize the volume attached to your Postgres instance.

### Cleaning up Incomplete Uploads from S3
One of the long standing complaints in the community about using a Nextcloud cluster with a S3 backend is that Nextcloud doesn't cleanup failed uploads automatically. This means that your S3 bucket continue to grow in size with in-accessible failed uploads even if the size of your Nextcloud files stays the same. To prevent this from happening, this Workflow as well as `maintenance.sh` scrape for incomplete uploads in your S3 bucket and delete those older than 1 week.

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
