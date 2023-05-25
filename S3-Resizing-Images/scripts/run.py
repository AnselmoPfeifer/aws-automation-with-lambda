import tempfile
import boto3
import os
from PIL import Image

DEST_BUCKET = os.environ['DEST_BUCKET']
S3 = boto3.client('s3')
SIZE = 128, 128


def generate_thumbnail(source_path, dest_path):
    print(f'INFO: generating thumbnail image')
    with Image.open(source_path) as image:
        image.thumbnail(SIZE)
        image.save(dest_path)


def lambda_handler(event, context):
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']
        thumb = f'thumb-{key}'
        with tempfile.TemporaryDirectory() as tmpDir:
            download_path = os.path.join(tmpDir, key)
            upload_path = os.path.join(tmpDir, thumb)
            S3.download_file(source_bucket, key, download_path)
            generate_thumbnail(download_path, upload_path)
            S3.upload_file(upload_path, DEST_BUCKET, thumb)
            print(f'INFO: thumbnail image was saved on {DEST_BUCKET}/{thumb}')
