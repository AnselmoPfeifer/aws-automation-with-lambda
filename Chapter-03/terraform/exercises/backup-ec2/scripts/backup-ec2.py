import boto3
from datetime import datetime

CLIENT = boto3.client('ec2')
STOP_LIST = []


def lambda_handler(event, context):
    print(f'INFO: starting process to shutdown EC2 instances nightly!')
    regions = [region['RegionName']
               for region in CLIENT.describe_regions()['Regions']]

    for region in regions:
        ec2 = boto3.resource('ec2', region_name=region)
        instances = ec2.instances.filter(
            Filters=[
                {
                    'Name': 'tag:Backup',
                    'Values': ['true']
                }
            ]
        )

        # ISO 8601 timestamp, i.e: 2023-05-20T14:01:58
        timestamp = datetime.utcnow().replace(microsecond=0).isoformat()
        for i in instances.all():
            print(f"INFO: instances with backup tag: {i.id}")
            for v in i.volumes.all():
                desc = f'Backup of {i.id}, volume {v.id}, created by Lambda Function in {timestamp}'
                print(desc)
                snapshot = v.create_snapshot(Description=desc)
                print(f'INFO: snapshot created {snapshot.id}')
