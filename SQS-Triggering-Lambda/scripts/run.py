import json
import os
import boto3
from datetime import datetime

QUEUE_NAME = os.environ['QUEUE_NAME']
MAX_QUEUE_MESSAGES = os.environ['MAX_QUEUE_MESSAGES']
DYNAMODB_TABLE = os.environ['DYNAMODB_TABLE']

sqs = boto3.resource('sqs')
dynamodb = boto3.resource('dynamodb')


def lambda_handler(event, context):
    queue = sqs.get_queue_by_name(QueueName=QUEUE_NAME)
    print("ApproximateNumberOfMessages:",
          queue.attributes.get('ApproximateNumberOfMessages'))

    for message in queue.receive_messages(
            MaxNumberOfMessages=int(MAX_QUEUE_MESSAGES)):
        # Write message to DynamoDB
        table = dynamodb.Table(DYNAMODB_TABLE)
        response = table.put_item(
            Item={
                'MessageId': message.message_id,
                'Body': message.body,
                'Timestamp': datetime.now().isoformat()
            }
        )
        print("INFO: wrote message to DynamoDB:", json.dumps(response))
        # Delete SQS message
        message.delete()
        print("INFO: deleted message:", message.message_id)
