import json
import boto3
from datetime import datetime

dynamodb = boto3.resource('dynamodb')


def lambda_handler(event, context):
    no_messages = str(len(event['Records']))
    print(f"INFO: found {no_messages} messages to process!")
    for message in event['Records']:
        print(f'INFO: message: {message}')
        table = dynamodb.Table('Message')
        response = table.put_item(
            Item={
                'MessageId': message['messageId'],
                'Body': message['body'],
                'Timestamp': datetime.now().isoformat()
            }
        )
        print("INFO: wrote message to DynamoDB:", json.dumps(response))
