#Find all the files modified in the last 16 mins for google
for i in `find /home/google/project -mmin -16 -type f  -name "*.zip" -exec ls {} +`;
do
	cp $i /tmp
done


Another script
###############

# this script deletes all file from /tmp which is older than 3 hours
# & deletes file older than one hour if disk utilization is higher than 90%
# DO NOT CHANGE any of the following variables unless required.
LOCATION=/tmp
FILESYSTEM=/dev/xvda1
CAPACITY=90

logger -t deleting_tmp_3hrs "Deleting the 3 hours old files from /tmp folder"
find $LOCATION -type f -mmin +360 -delete
find $LOCATION -type d -mmin +360 -delete

#Monitor if the disk utilization is more than 90% & delete files older than an hour
if [ $(df -P $FILESYSTEM | awk '{ gsub("%",""); capacity = $5 }; END { print capacity }') -gt $CAPACITY ]
then
  logger -t deleting_tmp_1hr "Deleting the one hour old files from /tmp folder"
  find $LOCATION -type f -mmin +60 -delete
  find $LOCATION -type d -mmin +60 -delete
fi
