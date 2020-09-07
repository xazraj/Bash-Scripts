#!/bin/bash

random=$((1 + RANDOM % 10))
if [ $random -le 5 ]; then
	token=removed
else
	token=removed
fi



#Function to send SMS Alerts
send_sms()
{
        mmins=`date  +%M`
        if [[ ( "$mmins" -eq 15 ) || ( "$mmins" -eq 29 ) || ( "$mmins" -eq 45 ) ]];
        then
        	echo "not sending sms"
        else
                echo "$1" | mailx -s "$2" <number>@messaging.sprintpcs.com
        fi
}



#Function to find the price of the stock
find_price()
{
  stock=$1
  url=https://cloud.iexapis.com/stable/stock/$stock/quote/latestPrice?token=$token
  printf `curl -s $url`
}




#Find the current price of the stocks
:> /root/price
cat /root/names | grep "#" | grep -v Name | cut -d "#" -f2 | while read line;
do
      current_price=$(find_price $line)
      printf "$line,$current_price\n" >> /root/price
done


#Logic to compare and send alerts
cat /root/names | grep -v "^#" | grep -v "^$" | grep -v Name | while read line;
do
        stock=$(echo "$line" | cut -d ',' -f1);
        threshold1=$(echo "$line" | cut -d ',' -f2);
        threshold2=$(grep $stock /root/price | cut -d "," -f2)
        rating=$(echo "$line" | cut -d',' -f3);

if [ $rating = "A" ]; then
	if (( $(echo "$threshold2 > $threshold1" |bc -l) )); then
        	grep "$stock is above $threshold" /tmp/report
        	if [ $? -ne 0 ];
       		then
          		echo "$stock is above $threshold" >> /tmp/report
          		send_sms STOCK-ALERT "$stock is above $threshold1 - CP($threshold2)"
		else
			echo "No Action Required"
        	fi
	fi
else

	if (( $(echo "$threshold2 < $threshold1" |bc -l) )); then
        	grep "$stock is below $threshold1" /tmp/report
        	if [ $? -ne 0 ];
        	then
          		echo "$stock is below $threshold1" >> /tmp/report
          		send_sms STOCK-ALERT "$stock is below $threshold1 - CP($threshold2)"
		else
			echo "No Action Required"
        	fi
	fi
fi
done


#Extra elements needed for alerts to work

Cron Entries
*/4 7-14 * * 1-5 root /root/correct.sh
30,37,42,46,49,54,58 6-7 * * 1-5 root /root/correct.sh
15 16 * * 1-5 root /root/call_both.sh
15,29,45 7-14 * * 1-5 root /root/call_both.sh

#Calling Both scripts
[root@stock ~]# more /root/call_both.sh
#!/bin/bash
#DO NOT RUN MANUALLY - let the cron fix the schedule
/root/clear_report.sh && sleep 5 && /root/correct.sh

