#!/bin/bash
curl -Is https://google.reports.com/login | grep HTTP | awk '{print $2}' >> /tmp/status
ndiff=$(($(wc -l /tmp/status | awk '{print $1}')-$(grep 200 /tmp/status | wc -l)))
if [ "$ndiff" -gt 1 ]; then
	echo "Google dashboard response code is not 200, restarting Google" > /tmp/info
 	<command to execute>
	cat /tmp/info | mailx -r reports@google.com -s "Google Dashboard restarted" reports@google.com
	:> /tmp/status && :> /tmp/info
elif [ "$ndiff" = 0 ]; then
            logger "Google is running fine at `date`"
            :> /tmp/status
fi
