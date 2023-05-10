# Getting Started

On this chapter I have created new example of lambda function with event trigger that will run every day.
- Overview of AWS Lambda
- Introduction to Boto3
- Creating an EC2 Instance with Lambda in AWS
    - terraform -chdir=terraform/ init
    - terraform -chdir=terraform/ plan -var=lambda_s3_bucket=<BUCKET_NAME>
    - terraform -chdir=terraform/ apply -var=lambda_s3_bucket=<BUCKET_NAME>
