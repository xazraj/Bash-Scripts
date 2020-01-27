#!/bin/bash

#Clearing out the report
:> /tmp/immreport

#Renaming the file for count comparison
\cp /tmp/nonzero /tmp/oldzero

#Writing all the current queues with non zero messages to a file
/usr/sbin/rabbitmqctl list_queues | grep immediate_queue | awk '{ if ($2 > 0) print $1 " " $2}' | tee /tmp/nonzero


for i in `cat /tmp/nonzero | cut -d " " -f1`;
	do
		grep $i /tmp/oldzero
		if [ $? -eq 0 ];
		then
			printf "Queue $i with non zero value has persisted for more than 5 mins \n" >> /tmp/immreport
			grep $i /tmp/oldzero >> /tmp/immreport
			grep $i /tmp/nonzero >> /tmp/immreport
			printf " \n \n" >> /tmp/immreport
		fi
done

count=$(wc -l /tmp/immreport | cut -d " " -f1)

if [ $count -gt 10 ]; then
	cat /tmp/immreport | mailx -r admin@google.com -s "Hermes Prod Immediate Queue > 5 mins" abhineetraj@hotmail.com
	
fi
