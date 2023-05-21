# Getting Started

* On this chapter I have created new example of lambda function with event trigger that will run every day.
- Overview of AWS Lambda
- Introduction to Boto3
- HANDS-ON LAB > Creating an EC2 Instance with Lambda in AWS

* Lab1 - Creating an EC2 Instance with Lambda in AWS
* Create new Keypair and download the file. 
* Get the first subnet id from VPC > Subnets to use on terraform commands
- terraform -chdir=terraform/lab init
- terraform -chdir=terraform/lab plan/apply -var=subnet_id=subnet-08ecfeaae96264cf1
* To test the result invoke the lambda and check on 2c2 the new instance was created, and connect by ssh. 
