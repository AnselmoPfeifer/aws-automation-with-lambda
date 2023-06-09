# Automating AWS with Lambda, Python, and Boto3

- [EC2-Creating-Instance](EC2-Creating-Instance/scripts/run.py)
- [Stopping EC2 Instances Nightly based on AWS Cloudwatch rules](EC2-Stopping-Instances/scripts/run.py)
- [Backing Up EC2 Instances](EC2-Backup-Instances/scripts/run.py)
- [Removing Unattached EBS Volumes](EC2-Removing-Unattached-EBS-Volumes/scripts/run.py)
- [De-registering Old AMIs](EC2-Deregistering-Old-AMIs/scripts/run.py)
- [AWS Instance Scheduler](EC2-Instance-Scheduler/aws-instance-scheduler.json)
  - The Instance Scheduler on AWS solution automates the starting and stopping of 
    Amazon Elastic Compute Cloud (Amazon EC2) and Amazon Relational Database Service (Amazon RDS) instances.
    Based on this [CloudFormation Template](EC2-Instance-Scheduler/aws-instance-scheduler.json)
- [Enabling AWS VPC Flow Logs with Automation](VPC-Flow-Logs-With-Automation/scripts/run.py)
```shell
Create CloudWatch rule for `CreateVpc` API call.
Navigate to CloudWatch.
    Click Create rule.
    Select Event Pattern.
    Service Name: EC2
    Event Type: AWS API Call via CloudTrail
    Specific Operation: "CreateVpc"
    Note that eventName sets CreateVpc in the preview
    Click Add target.
    Select Lambda function EnableVpcFlowLogs.
    Click Configure details.
------------------------------------------------
Create a VPC, and check the Flow Logs was enable.
```
- [DynamoDB-Managing-Tables](DynamoDB-Managing-Tables/README.md)
- [S3-Resizing-Images](S3-Resizing-Images/scripts/run.py)
  - pip install -t S3-Resizing-Images/scripts/ --platform manylinux2014_x86_64 --implementation cp --python 3.8 --only-binary=:all: --upgrade Pillow
- [DynamoDB-Importing-CSV](DynamoDB-Importing-CSV/scripts/run.py)
  - To test we need to upload the movies.csv file  to s3 bucket named: aws-lambda-csv-data
  - Check the data was imported to DynamoDB table!
- [SQS-Triggering-Lambda](SQS-Triggering-Lambda/scripts/run.py)
- [EC2-Automating-Resource-Tagging](EC2-Automating-Resource-Tagging/README.md)
- [IAM-Rotating-Access-key](IAM-Rotating-Access-key/README.md)


* Virtual environment
- Create Virtual env: python3 -m venv venv
- source venv/bin/activate
- pip install --upgrade pip
- pip install -r requirements.txt
-
* Terraform commands
- export TF_PATH=<Folder Name>
- terraform -chdir=${TF_PATH} init
- terraform -chdir=${TF_PATH} plan -var=name=<lambda-name>
- terraform -chdir=${TF_PATH} apply -var=name=<lambda-name>

* Invoking aws lambda using aws cli:
```shell
export NAME=<lambda name>
aws lambda invoke --invocation-type Event \
  --function-name ${NAME} \
  --invocation-type Event \
  --payload '{}' \
  response.json
```

## Reference:
- https://github.com/linuxacademy/content-lambda-boto3
- https://github.com/linuxacademy/la-aws-security_specialty
