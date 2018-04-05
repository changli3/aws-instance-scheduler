# AWS Instance Scheduler Lab
This is a tutorial on how to deploy AWS Instance Scheduler.

The CloudFormation template and explanation is based on the [AWS Instance Scheduler Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler/welcome.html). This tutorial is only for the main account. If you have cross account requirement, you need to do extra to set up roles in the remote account and use them as input for the CrossAccountRoles parameter.


## Run the Sheduler Stack CloudFormation template with AWS CLI

```
git clone https://github.com/changli3/awsd-instance-scheduler.git

cd awsd-instance-scheduler

aws cloudformation deploy --stack-name mySheduler01 --parameter-overrides Regions=us-east-1 CrossAccountRoles= --capabilities CAPABILITY_IAM --template-file cf.json 
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
aws cloudformation deploy --stack-name myShedulerConsole01 --parameter-overrides Ami=ami-428aa838 KeyName=TreaEBSLab VpcId=vpc-b3870dd6 SubnetID1=subnet-09f8ca52 SecurityGroupId=sg-58e1fc3d --capabilities CAPABILITY_IAM --template-file cf-bastion.yaml 
```
The autoscaling groups uses the CpuUtilization alarm to autoscale automatically. Because of this, you wouldn't have to bother making sure that your hosts can sustain the load.

## Working examples
```
export AWS_DEFAULT_REGION=us-east-1

scheduler-cli create-period --name "weekdays" --begintime 09:00 --endtime 18:00 --weekdays mon-fri --stack mySheduler01 

scheduler-cli create-schedule --name LondonWorkHours --periods "weekdays,weekends" --timezone Europe/London --stack mySheduler01

scheduler-cli describe-periods --stack mySheduler01

scheduler-cli describe-schedules --stack mySheduler01

scheduler-cli delete-schedule --name LondonWorkHours --stack mySheduler01

scheduler-cli delete-period --name weekdays --stack mySheduler01
```


