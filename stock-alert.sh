#!/bin/bash
apikey=removed


#Function to send SMS Alerts
send_sms()
{
	echo "$1" | mailx -s "$2" <phone-number>@messaging.sprintpcs.com
}


#Function to find the price of the stock
find_price()
{
	stock=$1
	apikey=removed
	url=https://financialmodelingprep.com/api/v3/profile/
	price=$(curl -s $url/$stock?apikey=$apikey  | jq '.[0].price')
	printf $price
}

#Command to find the price of the stock
#tprice=$(find_price TSLA)

#eg:- ROKU,109,B
cat /root/names | grep -v "^#" | while read line;
do
	stock=$(echo "$line" | cut -d ',' -f1);
	threshold1=$(echo "$line" | cut -d ',' -f2);
	threshold2=$(curl -s https://financialmodelingprep.com/api/v3/profile/$stock?apikey=$apikey | jq '.[0].price')
	rating=$(echo "$line" | cut -d',' -f3);

if [ $rating = "A" ]; then
	if (( $(echo "$threshold2 > $threshold1" |bc -l) )); then
				send_sms $stock "is above $threshold1"
	fi
else
	if (( $(echo "$threshold2 < $threshold1" |bc -l) )); then
				send_sms $stock "is below $threshold2"
	fi
fi
done
