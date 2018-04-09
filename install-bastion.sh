yum -y update
yum -y install ntp wget java-1.8.0-openjdk unzip

cd /home/ec2-user
wget https://github.com/changli3/awsd-instance-scheduler/raw/master/scheduler-cli.zip
unzip scheduler-cli.zip
python ./setup.py install

wget https://raw.githubusercontent.com/changli3/awsd-instance-scheduler/master/get-tag-csv.sh
wget https://raw.githubusercontent.com/changli3/awsd-instance-scheduler/master/tag-csv.py
chmod +x ./get-tag-csv.sh

