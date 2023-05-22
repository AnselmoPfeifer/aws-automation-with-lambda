import boto3
import os


def lambda_handler(event, context):
    try:
        vpc_id = event['detail']['responseElements']['vpc']['vpcId']
        print(f'INFO: vpc id: {vpc_id}')
        ec2 = boto3.client('ec2')
        response = ec2.describe_flow_logs(
            Filter=[
                {
                    'Name': 'resource-id',
                    'Values': [
                        vpc_id,
                    ]
                },
            ],
        )

        if len(response[u'FlowLogs']) != 0:
            print('INFO: vpc flow logs are ENABLED')
        else:
            print('INFO: vpc flow logs are DISABLED')

            print(f'INFO: FLOWLOGS_GROUP_NAME: ' + os.environ['FLOWLOGS_GROUP_NAME'])
            print('ROLE_ARN: ' + os.environ['ROLE_ARN'])

            response = ec2.create_flow_logs(
                ResourceIds=[vpc_id],
                ResourceType='VPC',
                TrafficType='ALL',
                LogGroupName=os.environ['FLOWLOGS_GROUP_NAME'],
                DeliverLogsPermissionArn=os.environ['ROLE_ARN'],
            )

            print(f"INFO: created new flow logs: {response['FlowLogIds'][0]}")

    except Exception as e:
        print(f'ERROR: reason {str(e)}')
