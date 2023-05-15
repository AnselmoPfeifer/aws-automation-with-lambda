# Getting Started

* On this chapter I have created new example of lambda function with event trigger that will run every day.
- Overview of AWS Lambda
- Introduction to Boto3
- Creating an EC2 Instance with Lambda in AWS
    - terraform -chdir=terraform/exercise init
    - terraform -chdir=terraform/exercise plan -var=lambda_s3_bucket=<BUCKET_NAME>
    - terraform -chdir=terraform/exercise apply -var=lambda_s3_bucket=<BUCKET_NAME>

* Invoking aws lambda using aws cli:
```shell
export LAMBDA_NAME='lab-creating-ec2'
aws lambda invoke --invocation-type Event \
  --function-name ${LAMBDA_NAME} \
  --invocation-type Event \
  --payload '{ "name": "Anselmo", "lastname": "Pfeifer" }' \
  response.json
```
* Lab1 - Creating an EC2 Instance with Lambda in AWS
* Create new Keypair and download the file. 
* Get the first subnet id from VPC > Subnets to use on terraform commands
- terraform -chdir=terraform/lab init
- terraform -chdir=terraform/lab plan -var=subnet_id=subnet-0390892c0e2815357
* To test the result invoke the lambda and check on 2c2 the new instance was created, and connect by ssh. 
