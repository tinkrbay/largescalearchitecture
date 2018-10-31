echo -n "Input your RDS Master endpoint name [ENTER]:"
read rdsmaster
echo -n "Input your RDS Read Replica endpoint name [ENTER]:"
read rdsreadreplica
echo -n "Input your Database name name [ENTER]:"
read dbname
echo -n "Input your Database Master Username [ENTER]:"
read dbmasterusername
echo -n "Input your Database Master Password [ENTER]:"
read dbmasterpassword
echo -n "Input the EFS DNS name [ENTER]:"
read efsdnsname
efsdnsname="$efsdnsname:/"
sudo yum install httpd php php-mysql php-pecl-memcached aws-kinesis-agent stress -y
sudo service httpd start
sudo chkconfig httpd on
cd /etc/httpd/conf/
sudo rm -rf httpd.conf
sudo wget https://s3.amazonaws.com/labs.thecloudgarage.com/megalab/httpd.conf
sudo service httpd restart
sudo chkconfig httpd on
cd /home/ec2-user/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xvf latest.tar.gz
cd /var/www/html/
sudo touch healthcheck.html
sudo mkdir blogs
cd /var/www/html/blogs/
sudo touch healthcheck.html
cd /home/ec2-user/
sudo mv wordpress/* /var/www/html/blogs/
cd /var/www/html/blogs/
sudo wget https://s3.amazonaws.com/labs.thecloudgarage.com/megalab/730aug2018/wp-config.php
sudo sed -i -- "s/northvirginia_rds_master_slave/$rdsmaster/g" wp-config.php
sudo sed -i -- "s/northvirginia_rds_readreplica/$rdsreadreplica/g" wp-config.php
sudo sed -i -- "s/dbname/$dbname/g" wp-config.php
sudo sed -i -- "s/dbmasterusername/$dbmasterusername/g" wp-config.php
sudo sed -i -- "s/dbmasterpassword/$dbmasterpassword/g" wp-config.php
sudo wget http://downloads.wordpress.org/plugin/hyperdb.zip
sudo unzip hyperdb.zip
sudo cp /var/www/html/blogs/hyperdb/db.php /var/www/html/blogs/wp-content/
sudo chmod a-w /var/www/html/blogs/wp-content/db.php
cd /var/www/html/blogs/
sudo wget https://s3.amazonaws.com/labs.thecloudgarage.com/megalab/db-config.php
cd /home/ec2-user/
sudo wget https://downloads.wordpress.org/plugin/w3-total-cache.0.9.6.zip
sudo unzip w3-total-cache.0.9.6.zip
sudo mv /home/ec2-user/w3-total-cache /var/www/html/blogs/wp-content/plugins
cd /var/www/html/blogs/wp-content/
sudo sudo mkdir uploads
sudo echo ""$efsdnsname"	/var/www/html/blogs/wp-content/uploads/	nfs4	nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,_netdev,noresvport	0	0" >> /etc/fstab
sudo mount -a
cd /home/ec2-user/
sudo wget https://github.com/tinkrbay/aws-metadata-php-page/archive/master.zip
sudo unzip master.zip
sudo mkdir /var/www/html/blogs/ec2metadatascript
sudo mv aws-metadata-php-page-master/* /var/www/html/blogs/ec2metadatascript/
sudo chmod -R 755 /var/www/html/
sudo chown -R apache.apache /var/www/html/
sudo chmod -R 755 /var/www/html/blogs/wp-content/uploads/
sudo chown -R apache.apache /var/www/html/blogs/wp-content/uploads/
cd /etc/aws-kinesis/
sudo rm -rf agent.json
sudo wget https://s3.amazonaws.com/labs.thecloudgarage.com/Kinesis+streams/agent.json
sudo chmod -R 755 /var/log/httpd/
sudo chown -R aws-kinesis-agent-user /var/log/httpd
sudo service aws-kinesis-agent start
sudo chkconfig aws-kinesis-agent on
sudo service httpd restart