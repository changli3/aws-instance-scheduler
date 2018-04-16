# AWS Instance Scheduler Lab
This is a tutorial on how to deploy AWS Instance Scheduler.

The CloudFormation template and explanation is based on the [AWS Instance Scheduler Implementation Guide](https://docs.aws.amazon.com/solutions/latest/instance-scheduler/welcome.html). This tutorial is only for the main account. If you have cross account requirement, you need to do extra to set up roles in the remote account and use them as input for the CrossAccountRoles parameter.


## Run the Sheduler Stack CloudFormation template with AWS CLI

```
git clone https://github.com/changli3/aws-instance-scheduler.git

cd aws-instance-scheduler

aws cloudformation deploy --stack-name mySheduler01 --parameter-overrides Regions=us-east-1 CrossAccountRoles= --capabilities CAPABILITY_IAM --template-file cf.json 
```

For gov-cloud, use this cf-gov.yaml -
```
aws cloudformation deploy --stack-name mySheduler01 --parameter-overrides Regions=us-gov-west-1 CrossAccountRoles= --capabilities CAPABILITY_IAM --template-file cf-gov.json 
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
aws cloudformation deploy --stack-name myConsole01 --parameter-overrides Ami=ami-428aa838 KeyName=TreaEBSLab VpcId=vpc-b3870dd6 SubnetID1=subnet-09f8ca52 SecurityGroupId=sg-58e1fc3d --capabilities CAPABILITY_IAM --template-file cf-bastion.yaml 
```


This template launch a small Linux machine for you to manage the schedule if you do not already have a management machine. It installs scheduler-cli and provides some utility script, for examples, batch tagging of instances via a csv file. Please select an Amazon Linux AMI (login as ec2-user).

## Working with Console

### Availabe scheduler-cli Commands
* create-period
* create-schedule
* delete-period
* delete-schedule
* describe-periods
* describe-schedules
* describe-schedule-usage
* update-period
* update-schedule
* help

```
export AWS_DEFAULT_REGION=us-east-1

scheduler-cli create-period --name "weekdays" --begintime 09:00 --endtime 18:00 --weekdays mon-fri --stack mySheduler01 

scheduler-cli create-schedule --name AmericaEastOfficeHours --periods "weekdays,weekends" --timezone US/Eastern --stack mySheduler01

scheduler-cli describe-periods --stack mySheduler01

scheduler-cli describe-schedules --stack mySheduler01

scheduler-cli delete-schedule --name AmericaEastOfficeHours --stack mySheduler01

scheduler-cli delete-period --name weekdays --stack mySheduler01
```

### Availabe tagging Commands
* aws ec2 create-tags
* aws ec2 delete-tags
* aws ec2 describe-tags
* aws rds create-tags
* aws rds delete-tags
* aws rds describe-tags


```
#tag instances with schedule AmericaEastOfficeHours
aws ec2 create-tags --resources i-3fba6a96 i-5000b561 --tags "Key=RunSchedule,Value=AmericaEastOfficeHours"

#check all instances with schedule AmericaEastOfficeHours
aws ec2 describe-tags --filters "Name=key,Values=RunSchedule" "Name=value,Values=AmericaEastOfficeHours" "Name=resource-type,Values=instance"

#delete all instances with schedule AmericaEastOfficeHours
aws ec2 delete-tags --resources i-3fba6a96 i-5000b561 --tags Key=RunSchedule

#check all instances with a schedule
aws ec2 describe-tags --filters "Name=key,Values=RunSchedule" "Name=resource-type,Values=instance"

```

## Batch tagging with csv file
Create csv file like this - ("instance-id","schedule-name"):
```
i-3fba6a96,AmericaEastOfficeHours
i-5000b561,AmericaEastOfficeHours
```

If the file is local (for examples: instance-tags.csv), run -
```
python tag-csv.py instance-tags.csv
```

If the file is remote (for examples: https://raw.githubusercontent.com/changli3/aws-instance-scheduler/master/instance-tags.csv), run -
```
./get-tag-csv.sh https://raw.githubusercontent.com/changli3/aws-instance-scheduler/master/instance-tags.csv
```


## Remove all testing resources after the lab
```
aws cloudformation delete-stack  --stack mySheduler01

aws cloudformation delete-stack  --stack myConsole01
```

# Use in AWS GovCloud
There are some glitches in the AWS GovCloud to load the Lambda from direct S3 sources. You have to manually upload the code from the lambda-scheduler.zip provided in this folder.

## Steps

### Step 1. Launch Sheduler Stack CloudFormation

```
aws cloudformation deploy --stack-name mySheduler01 --parameter-overrides Regions=us-gov-west-1 CrossAccountRoles= --capabilities CAPABILITY_IAM --template-file cf-gov-01.json  
```

### Step 2. Upload the Lambda Code
This is a manual step - please go to lambda function and find the function created by the CloudFormation and upload the code from zip file lambda-scheduler.zip and click on save.

### Step 3. Launch Sheduler Provision CloudFormation Stack

```
aws cloudformation deploy --stack-name mySheduler01-02 --parameter-overrides Regions=us-gov-west-1 CrossAccountRoles=  LambdaArn="ArnOfYourNewLambdaFunction" ConfigTable="ArnOfYourNewDynamoDBConfigTable" --template-file cf-gov-02.json
```

### Step 4. Launch an Management Bastion with AWS CLI
```
aws cloudformation deploy --stack-name myConsole01 --parameter-overrides Ami=ami-b2d056d3 KeyName=govTestKey VpcId=vpc-7808751d SubnetID1=subnet-22293555 SecurityGroupId=sg-8ef93bea --capabilities CAPABILITY_IAM --template-file cf-bastion.yaml 
```

Please use your parameter and select an Amazon Linux AMI in the GovCloud and make sure the subnet has default internet access when launch new instances.

### Step 5. Logon to the Console

```
export AWS_DEFAULT_REGION=us-gov-west-1
```

The remaining operation is same as the above in the public cloud.