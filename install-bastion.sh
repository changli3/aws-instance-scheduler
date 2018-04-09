yum -y update
yum -y install ntp wget java-1.8.0-openjdk unzip

cd /home/ec2-user
wget https://github.com/changli3/awsd-instance-scheduler/raw/master/scheduler-cli.zip
unzip scheduler-cli.zip
python ./setup.py install
wget https://github.com/changli3/awsd-instance-scheduler/blob/master/tag-csv.py
wget https://github.com/changli3/awsd-instance-scheduler/blob/master/get-tag-csv.sh
chmod +x ./get-tag-csv.sh

