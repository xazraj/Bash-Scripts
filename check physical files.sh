#!/bin/ksh
echo "" > /tmp/abhineet/output;
cat /tmp/abhineet/files_test | while read line;
do
ids = $(echo "$line" | cut -d',' -f1);
echo $ids
file=$(echo "$line" | cut -d',' -f 2-);
echo $file
if [[ ! -f "$file" ]] ;
then echo "$ids ,File $file doesn't exist" >> /tmp/abhineet/output;
fi;
done
