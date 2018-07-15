#!/bin/bash
#Creating a temp file
touch /tmp/acc && :> /tmp/acc
# You can either pass the github username in the script or pass it as an argument
printf "\n Enter the password for the github account \n"
read pass
printf "\n Enter the username which needs to be searched in the collaborators\n"
read uid
for url in `cat /Users/abhineetraj/scripts/urls`
do
curl -s -u "github_username":$pass $url | grep $uid > /dev/null
if [ $? -eq 0 ]; then
corrurl=$(echo $url | awk -F "/" '{print $6 }')
echo " https://github.com/github_username/$corrurl/settings/collaboration" >> /tmp/acc
#Comment the following line if you don't want to open the repos on chrome, it works on Mac OSX
/usr/bin/open -a "/Applications/Google Chrome.app" "https://github.com/github_username/$corrurl/settings/collaboration"
#Following line can be used if you need to delete the collaborators through the script
#curl -X DELETE -i -u "user:pass" https://api.github.com/repos/user/repo/collaborators/john.doe
fi
done
cat /tmp/acc
###This is how the urls file looks like
#https://api.github.com/repos/github_username/repo_name/collaborators
#https://api.github.com/repos/github_username/airflow/collaborators
#https://api.github.com/repos/github_username/worldmap/collaborators
