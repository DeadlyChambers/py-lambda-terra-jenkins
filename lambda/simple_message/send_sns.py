'''
    Create a new SNS Message for a hardcoded SNS Topic
'''
from datetime import datetime
import json
import pprint
import boto3
#TODO Ensure versioning is increment in pipeline
VERSION = '1.0.4'

def lambda_handler(event, context):
    '''
    The method called when Lambda Function is deployed to AWS
    Args:
        event ([string]): Just passing if it is ran locally for now
        context ([type]): Not being used
    Returns:
        [string]: The subject of the SNS message
    '''
    message = 'AWS'
    if event == 'local':
        message = event
    print(f'Simple Message Lambda v{VERSION}: Running the Lambda Handler - Running from {message}')
    time= datetime.now()
    time_format = time.strftime('%H:%M:%S')
    print(time_format)
    subject = f'Jenkins Deployed Lambda Message v{VERSION} - {time_format} from {message}'
    
    client = boto3.client('sns', region_name='us-east-1')
    paginator = client.get_paginator('list_topics')
    page_iterator = paginator.paginate().build_full_result()
    cur_topic = "na"
    for page in page_iterator['Topics']:
        topic_name = page['TopicArn']
        print(topic_name)
        if 'ds-operations-lambda-sns' == topic_name:
            cur_topic = topic_name
            break
    if cur_topic == "na":
        print('Topic not found')
        return "topic not found"
    client.publish(
        #TODO make this resource to fix the awful naming
        TargetArn=cur_topic,
        Message=json.dumps({'default': 'Testing default python SNS message',
                            'sms': 'Testing sms py SNS message',
                            'email': 'Testing email python SNS message'}),
        Subject = subject,
        MessageStructure='json'
    )
    print(subject)
    return subject

if __name__ == '__main__':
    print(f'Simple Message Lambda v{VERSION}: Running the Main Method')
    lambda_handler('local', '')
