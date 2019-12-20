#!/usr/bin/env bash

set -e

# Dump route 53 zones to a text file and upload to S3.

BACKUP_DIR=/home/<user>/dns-backup
BACKUP_BUCKET=<bucket>
# Use full paths for cron
CLIPATH="/usr/local/bin"

# Dump all zones to a file and upload to s3
function backup_all_zones () {
  local zones
  # Enumerate all zones
  zones=$($CLIPATH/aws route53 list-hosted-zones | jq -r '.HostedZones[].Id' | sed "s/\/hostedzone\///")
  for zone in $zones; do
  echo "Backing up zone $zone"
  $CLIPATH/aws route53 list-resource-record-sets --hosted-zone-id $zone > $BACKUP_DIR/$zone.json
  done

  # Upload backups to s3
  $CLIPATH/aws s3 cp $BACKUP_DIR s3://$BACKUP_BUCKET --recursive --sse
}

# Create backup directory if it doesn't exist
mkdir -p $BACKUP_DIR
# Backup up all the things
time backup_all_zones
