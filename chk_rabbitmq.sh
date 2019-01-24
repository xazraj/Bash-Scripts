#!/bin/bash
#Queuename Sample
#sms-compose,10000,abc,abc
echo "" > /tmp/report;
cat /var/local/adm/queuename | while read line;
do
qname=$(echo "$line" | cut -d',' -f1);
threshold1=$(echo "$line" | cut -d',' -f2);
avoid1=$(echo "$line" | cut -d',' -f3);
avoid2=$(echo "$line" | cut -d',' -f4);
threshold2=$(/usr/sbin/rabbitmqctl list_queues | grep $qname |grep -v $avoid1 | grep -v $avoid2 | awk '{print $2}');
if [ $threshold2 -gt $threshold1 ]; then
        printf "\n Queue \"$qname\" has $threshold2 messages crossing the threshold of $threshold1\n" | tee -a /tmp/report
fi
done
count=$(wc -l /tmp/report | cut -d " " -f1)
if [ $count -gt 1 ]; then
cat /tmp/report | mailx -r PlatformPROD-RMQ@mpulsemobile.com -s "Platform Prod Queue -Threshold cross" abhineetraj@hotmail.com
fi
