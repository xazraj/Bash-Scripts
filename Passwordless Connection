To copy ssh key to authorized key of the remote server
cat /tmp/id/id_rsa.pub | ssh root@servername 'cat >> .ssh/authorized_keys && echo "Key copied"'

To make passwordless connection
#!/bin/bash
#Script taking the remote server IP as an argument
if [ "$1" != "" ];
then
printf "\n ****************Initiating the process************* \n\n"
printf "\n ****************You need to enter the password for $1************* \n\n"
#Creating a .ssh directory on the remote server
ssh uid@$1 mkdir -p .ssh

#Command to create the pub file ----- "ssh-keygen -t rsa"
#Copying the public key (uid0) from current server to authorized keys (uid) on the remote server
cat /home/uid0/.ssh/id_rsa.pub | ssh uid@$1 'cat >> .ssh/authorized_keys'
ssh uid@$1 "chmod 700 .ssh; chmod 644 .ssh/authorized_keys"
else
printf "\n"
echo "Please input an argument after invoking the script, for eg:- ./passwordless_connection (Server IP)"
fi
