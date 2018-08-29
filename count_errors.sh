#!/bin/bash
cd /var/logs/`date +%Y-%m`
file=$(ls -t https_error-* | head -1)
printf "\n      ***Below are Connection Timed Out Errors *** \n" > /tmp/reports

#following lines needs to be modfied based on the log output and format
grep `date -d now-4hours +%d/%b/%Y-%H` | sed  's/-/ /g' $file | grep -i account_id |  >> /tmp/reports
grep `date -d now-4hours +%d/%b/%Y-%H` | sed  's/-/ /g' $file | grep -i "Connection timed out"  >> /tmp/reports
printf "Checking for 4 hours \n"

#Counting the no of 504's with respect to each server
server2=$(grep 192.127.215.33 /tmp/reports | wc -l)
server4=$(grep 192.220.168.242 /tmp/reports | wc -l)
server5=$(grep 192.255.167.192 /tmp/reports | wc -l)
server6=$(grep 192.227.183.192 /tmp/reports | wc -l)

echo "App6 count --> $server6" | cat - /tmp/reports > temp && \mv temp /tmp/reports
echo "App5 count --> $server5" | cat - /tmp/reports > temp && \mv temp /tmp/reports
echo "App4 count --> $server4" | cat - /tmp/reports > temp && \mv temp /tmp/reports
echo "App2 count --> $server2" | cat - /tmp/reports > temp && \mv temp /tmp/reports

#Counting the lines in the reports and sending out the email reports.
count=$(wc -l /tmp/reports | cut -d " " -f1)
to=7
no="$(($count-$to))"
if [ $count -gt 7 ]; then
cat /tmp/reports | mailx -r ERROR-504@google.com -s "$no - 504's in the last 4 hours" abhineet.raj@google.com
fi
