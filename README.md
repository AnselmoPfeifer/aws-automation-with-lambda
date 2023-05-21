# Automating AWS with Lambda, Python, and Boto3

# Elastic Compute Cloud (EC2)
On this chapter I worked with Function Lambda to apply the:
- [Stopping EC2 Instances Nightly based on AWS Cloudwatch rules](../stop-ec2/scripts/stop-ec2.py)
- [Backing Up EC2 Instances](../backup-ec2/scripts/backup-ec2.py)
- [Removing Unattached EBS Volumes](../remove-unattached-volumes/scripts/remove-unattached-volumes.py')
- Deregistering Old AMIs
- AWS Instance Scheduler
* HANDS-ON LAB > Enabling AWS VPC Flow Logs with Automation


## Virtual environment
- Create Virtual env: python3 -m venv venv
- source venv/bin/activate
- pip install --upgrade pip
- pip install -r requirements.txt
-
## Terraform commands
- export TF_PATH=terraform/exercise
- terraform -chdir=${TF_PATH} init
- terraform -chdir=${TF_PATH} plan -var=subnet_id=<subnet_id>
- terraform -chdir=${TF_PATH} apply -var=subnet_id=<subnet_id>

* Invoking aws lambda using aws cli:
```shell
export LAMBDA_NAME='backup-ec2-instances'
aws lambda invoke --invocation-type Event \
  --function-name ${LAMBDA_NAME} \
  --invocation-type Event \
  --payload '{}' \
  response.json
```

- [CHAPTER 1](01-Introduction/README.md)
- [CHAPTER 2](Chapter-02/README.md)
- [CHAPTER 3](Chapter-03/README.md)
