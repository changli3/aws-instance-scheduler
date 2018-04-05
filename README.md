# AWS Instance Scheduler Lab
This is a tutorial on how to deploy AWS Instance Scheduler.

The CloudFormation template and explanation is based on the [AWS Instance Scheduler Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler/welcome.html). This tutorial is only for the main account. If you have cross account requirement, you need to do extra to set up roles in the remote account and use them as input for the CrossAccountRoles parameter.


## Run the Sheduler Stack CloudFormation template with AWS CLI

```
git clone https://github.com/changli3/awsd-instance-scheduler.git

cd awsd-instance-scheduler

aws cloudformation deploy --stack-name mySheduler01 --parameter-overrides Regions=us-east-01 CrossAccountRoles= --capabilities CAPABILITY_IAM --template-file cf.json 
```

This will take about 10 minutes to get the instances started. Once it is completed, you can check for following resources:
* CF Stack
* DynamoDB
* CloudWatch Events
* Lambda Function
* IAM Role / Policies
* SNS Topic


## Launch an Management Bastion with AWS CLI
```
aws cloudformation deploy --stack-name myShedulerConsole01 --parameter-overrides Ami=ami-1853ac65 KeyName=TreaEBSLab VpcId=vpc-b3870dd6 SubnetID1=subnet-09f8ca52 --template-file cf-bastion.json 
```
The autoscaling groups uses the CpuUtilization alarm to autoscale automatically. Because of this, you wouldn't have to bother making sure that your hosts can sustain the load.

## Stack Monitoring
Each node has Prometheus installed. You can monitor the instances via the Grafana instance. You need to add data source and setup the dashboard. Please refer to [this guide] (https://www.robustperception.io/setting-up-grafana-for-prometheus/) for  further readings.

## Alarms
In order to be sure that you have set up the proper limits for your containers, the following alerts have been but into place:
* NetworkInAlarm
* RAMAlarmHigh
* NetworkOutAlarm
* IOWaitAlarmHigh
* StatusAlarm
  
These CloudWatch alarms will send an email each time the limits are hit so that you will always be in control of what happens with your stack.
      
## Backup
A cronjob has been set up to run every 3 days on the ASG hosts that dump the data in an S3 bucket that is created inside the template.
        