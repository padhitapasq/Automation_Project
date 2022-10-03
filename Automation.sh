#Automation Script to install apache2 server and check its running status


#1- Variable Declaration
timestamp=$(date '+%d%m%Y-%H%M%S')
myname="Tapas"
s3bucket="upgrad-tapaspadhi"

#2- Updating the system packages
sudo apt update -y

#3- Installing the apache2 package if it is not already installed
Is_Apache_Present=$(dpkg --list | grep apache2 | cut -d ' ' -f 3 | head -1)
if [ "$Is_Apache_Present" == "" ]
        then
	        echo "Apache2 is not installed, Installing now !!"
                sudo apt-get install apache2 -y
else
        echo "apache2 is already installed in your machine"
fi

#4- Ensure that the apache2 service is running. 

Is_Server_Running=$(systemctl --type=service | grep apache2 | awk {'print $4'})
if [ "$Is_Server_Running" != "running" ]
        then
                echo "apache2 is not running, starting now !!"
                sudo /etc/init.d/apache2 start
else
        echo "apache2 is already running in your machine"
fi

#5- Creating a tar archive of apache2 access/error logs
tar -cvf /tmp/$myname-httpd-logs-$timestamp.tar /var/log/apache2/*.log

#6- Running the awscli command and copy the archive to the s3 bucket.
aws s3 cp /tmp/$myname-httpd-logs-$timestamp.tar s3://${s3bucket}/${myname}-httpd-logs-${timestamp}.tar

#Task-3

if [ -f "/var/www/html/inventory.html" ];
then

        printf "<p>" >> /var/www/html/inventory.html
        printf "\n\t$(ls -t /tmp | grep httpd | head -1 | cut -d '-' -f 2,3)" >> /var/www/html/inventory.html
        printf "\t\t$(ls -t /tmp | grep httpd | head -1 | cut -d '-' -f 4,5 | cut -d '.' -f 1)" >> /var/www/html/inventory.html
        printf "\t\t\t $(ls -t /tmp | grep httpd | head -1 | cut -d '.' -f 2)" >> /var/www/html/inventory.html
        printf "\t\t\t\t$(ls -sht /tmp | grep httpd | head -1 | awk {'print $1'})" >> /var/www/html/inventory.html
        printf "</p>" >> /var/www/html/inventory.html

else
        touch /var/www/html/inventory.html
        printf "<p>" >> /var/www/html/inventory.html
        printf "\tLog_Type\tDate_Created\tType\tSize" >> /var/www/html/inventory.html
        printf "</p>" >> /var/www/html/inventory.html
        printf "<p>" >> /var/www/html/inventory.htm
        printf "\n\t$(ls -t /tmp | grep httpd | head -1 | cut -d '-' -f 2,3)" >> /var/www/html/inventory.html
        printf "\t\t$(ls -t /tmp | grep httpd | head -1 | cut -d '-' -f 4,5 | cut -d '.' -f 1)" >> /var/www/html/inventory.html
        printf "\t\t\t $(ls -t /tmp | grep httpd | head -1 | cut -d '.' -f 2)" >> /var/www/html/inventory.html
        printf "\t\t\t\t$(ls -sht /tmp | grep httpd | head -1 | awk {'print $1'})" >> /var/www/html/inventory.html
        printf "</p>" >> /var/www/html/inventory.html

fi

# Cron Job to run every minute

if [ -f "/etc/cron.d/automation" ];
then
	echo "Cron job file is present"
else
	sudo touch /etc/cron.d/automation
	sudo echo "* * * * * root /root/Automation_Project/auotmation.sh" > /etc/cron.d/automation
fi