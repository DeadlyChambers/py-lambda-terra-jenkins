"""
    Create the VPC and EC2 stacks
    Returns:
        [type]: The stack of the EC2 created or already existing
"""
import sys
from datetime import datetime
import os
import traceback
import logging
import json
import boto3


FORMAT = "[%(filename)s:%(lineno)s - %(funcName)20s() ] %(message)s"
logging.basicConfig(format=FORMAT, level=logging.INFO)

logger = logging.getLogger("root")

def lambda_handler(event, context):
    '''
    Lambda handler function. The default function when the
    lambda function is being called
    Args:
        event ([type]): This should be a Pull Request merged
        that is passed from EventBridge
        context ([type]): [description]
    Returns:
        [type]: [description]
    '''
    logger.info("Simple Message Lambda: Running the Lambda Handler - %s ", event["Resources"])
    time= datetime.now()
    time_format = time.strftime("%H:%M:%S")
    print(time_format)
    
    boto3.client('sns')
    client = boto3.client('sns')
    response = client.publish(
    TargetArn='arn:aws:sns:us-east-1:047476809233:ds-operations-lambda-sns-MySnsTopic-LZYME5CPK0NF',
        Message=json.dumps({'default': 'simple python sns message',
                            'sms': 'short python message',
                            'email': 'testing a python test message'}),
        Subject=f'Jenkins Deployed Lambda Message {time_format}',
        MessageStructure='json'
    )

if __name__ == "__main__":
    logger.info("Simple Message Lambda: Running the Main")
    lambda_handler('', '')