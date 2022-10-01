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