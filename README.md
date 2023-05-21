# Automating AWS with Lambda, Python, and Boto3

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

- [CHAPTER 1](Chapter-01/README.md)
- [CHAPTER 2](Chapter-02/README.md)
- [CHAPTER 3](Chapter-03/README.md)
