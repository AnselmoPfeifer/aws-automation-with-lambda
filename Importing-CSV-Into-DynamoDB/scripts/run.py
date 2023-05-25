import os
import tempfile
import boto3
import csv

S3 = boto3.client('s3')
DYNAMODB = boto3.resource('dynamodb')
TABLE = DYNAMODB.Table('Movies')


def lambda_handler(event, context):
    print('INFO: starting import process to dynamodb')
    for record in event['Records']:
        print(f'INFO: import record: {record}')
        source_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        print(f'INFO: create Temporary Directory')
        with tempfile.TemporaryDirectory() as tmpDir:
            download_path = os.path.join(tmpDir, key)
            S3.download_file(source_bucket, key, download_path)
            itens = read_csv(download_path)

            print(f'INFO: put item on dynamodb table!')
            with TABLE.batch_writer() as batch:
                for item in itens:
                    batch.put_item(Item=item)


def read_csv(file):
    items = []
    print(f'INFO: open file {file}')
    with open(file) as csvfile:
        reader = csv.DictReader(csvfile)

        print(f'INFO: reading data for each line on reader!')
        for row in reader:
            data = {'Meta': {}, 'Year': int(row['Year']), 'Title': row['Title'] or None}
            data['Meta']['Length'] = int(row['Length'] or 0)
            data['Meta']['Subject'] = row['Subject'] or None
            data['Meta']['Actor'] = row['Actor'] or None
            data['Meta']['Actress'] = row['Actress'] or None
            data['Meta']['Director'] = row['Director'] or None
            data['Meta']['Popularity'] = row['Popularity'] or None
            data['Meta']['Awards'] = row['Awards'] == 'Yes'
            data['Meta']['Image'] = row['Image'] or None
            data['Meta'] = {k: v for k,
                                     v in data['Meta'].items() if v is not None}
            items.append(data)
    return items
