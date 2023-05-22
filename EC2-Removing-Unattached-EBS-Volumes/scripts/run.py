import boto3


def lambda_handler(event, context):
    print(f'INFO: starting process to prune ec2 volumes nightly!')
    ec2 = boto3.client('ec2')
    regions = [region['RegionName']
               for region in ec2.describe_regions()['Regions']]

    for region in regions:
        ec2 = boto3.resource('ec2', region_name=region)
        volumes = ec2.volumes.filter(
            Filters=[
                {
                    'Name': 'status', 'Values': ['available']
                }
            ]
        )
        print(f'INFO: checking the available volumes to cleanup!')
        for volume in volumes:
            v = ec2.Volume(volume.id)
            print(f'INFO: delete the volume {v.id}, size: {v.size}')
            v.delete()
