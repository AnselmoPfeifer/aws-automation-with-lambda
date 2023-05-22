# Automating AWS with Lambda, Python, and Boto3

# Elastic Compute Cloud (EC2)
- [EC2-Creating-Instance](EC2-Creating-Instance/scripts/run.py)
- [Stopping EC2 Instances Nightly based on AWS Cloudwatch rules](EC2-Stopping-Instances/scripts/run.py)
- [Backing Up EC2 Instances](EC2-Backup-Instances/scripts/run.py)
- [Removing Unattached EBS Volumes](EC2-Removing-Unattached-EBS-Volumes/scripts/run.py)
- [Deregistering Old AMIs](EC2-Deregistering-Old-AMIs/scripts/run.py)
- [AWS Instance Scheduler](EC2-Instance-Scheduler/scripts/run.py)
* HANDS-ON LAB > Enabling AWS VPC Flow Logs with Automation


## Virtual environment
- Create Virtual env: python3 -m venv venv
- source venv/bin/activate
- pip install --upgrade pip
- pip install -r requirements.txt
-
## Terraform commands
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

- [CHAPTER 1](01-Introduction/README.md)
- [CHAPTER 2](Chapter-02/README.md)
- [CHAPTER 3](Chapter-03/README.md)
