import boto3

CLIENT = boto3.client('ec2')
# Added here the instances ids to check and stop
STOP_LIST = []


def lambda_handler(event, context):

    print(f'INFO: starting process to shutdown EC2 instances nightly!')
    regions = [region['RegionName']
               for region in CLIENT.describe_regions()['Regions']]

    for region in regions:
        ec2 = boto3.resource('ec2', region_name=region)
        print(f'INFO: checking instances on region: {region}')
        instances = ec2.instances.filter(
            Filters=[
                {
                    'Name': 'instance-state-name',
                    'Values': ['running']
                }
            ]
        )

        for instance in instances:
            if instance.id in STOP_LIST:
                print(f'INFO: stopping instance: {instance.id}')
                instance.stop()
