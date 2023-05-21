import boto3
import datetime
from dateutil.parser import parse


def days_old(date):
    parsed = parse(date).replace(tzinfo=None)
    diff = datetime.datetime.now() - parsed
    return diff.days


def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    regions = [region['RegionName']
               for region in ec2.describe_regions()['Regions']]
    for region in regions:
        print(f'INFO: checking images on region: {region}')
        ec2 = boto3.client('ec2', region_name=region)
        images = ec2.describe_images(Owners=['self'])['Images']
        for image in images:
            creation_date = image['CreationDate']
            age_days = days_old(creation_date)
            image_id = image['ImageId']

            if age_days >= 2:
                print(f'INFO: deregister image: {image_id}, created {creation_date}, days old: {age_days}')
                #ec2.deregister_image(ImageId=image_id)
