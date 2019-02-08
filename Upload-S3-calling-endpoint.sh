#!/usr/bin/env bash
cd /tmp/test
inotifywait -m -q -e close_write --format %f . | while IFS= read -r file; do
aws s3 cp $file s3://bucketname --profile awsprofile
if [ $? -eq 0 ]; then
#Including the following 4 lines to have the script call the URL directly.
id=$(echo "$file" | cut -d'-' -f1);
#Checking if the notification has already been called before for the id
cat /tmp/test/id | grep $id
if [ $? -ne 0 ]; then
#Calling the notification automatically
echo -e "Calling the following End point at `date`  www.google.com \n" >> /tmp/logs
#Calling the notification
curl "www.google.com"
echo $id >> /tmp/test/id
fi
fi
done
