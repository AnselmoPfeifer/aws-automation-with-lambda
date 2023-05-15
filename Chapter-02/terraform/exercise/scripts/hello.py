import json


def lambda_handler(event, context):
    print(f'Event: ${event}')
    print(f'Context ${context}')

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from AWS Lambda')
    }
