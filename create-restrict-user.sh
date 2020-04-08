#!/bin/bash
if [ "$1" = "" ]; then
	printf "\n Please enter a username and password & run the script again\n"
else
if [ "$2" = "" ]; then
	printf "\n Please enter a password for the account \"$1\" and run the script again\n"
else
	sudo useradd -g sftpaccess -s /bin/false -m -d /home/$1 $1
	echo $2 | passwd $1 --stdin >> /root/.bash_history
	sudo chown root: /home/$1
	sudo chmod 755 /home/$1
	sudo mkdir /home/$1/{archive,pickup,reports}
	touch /home/$1/.bash_history && chown $1: /home/$1/.bash* && chmod 640 /home/$1/.bash*
	sudo chmod 750 /home/$1/{delta,gamma}
	sudo chown $1:sftpaccess /home/$1/{archive,pickup,reports}
	printf "\n *** SFTP account \"$1\" has been created successfully ***\n"
	fi
fi



Comment out following line
#Subsystem       sftp    /usr/libexec/openssh/sftp-server

and then add this

Subsystem sftp internal-sftp

#Including the following lines to restrict user to its own home directory
Match Group sftpaccess
   ChrootDirectory %h
   ForceCommand internal-sftp
   AllowTcpForwarding no
   X11Forwarding no
    
service ssh restart   
