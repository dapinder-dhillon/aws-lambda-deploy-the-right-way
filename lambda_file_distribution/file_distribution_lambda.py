import boto3
import logging
import os
import requests
import sys
import urllib
from botocore.client import Config
from botocore.exceptions import ClientError

logger = logging.getLogger()
logger.setLevel(logging.INFO)


# -----------------------------------------------------------------------------
# Lambda Calling Handler Function ( main )
# -----------------------------------------------------------------------------

def lambda_handler(event, context):
    logger.info("Loading Lambda Function")

    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')
    logger.info("S3 Bucket:" + bucket + " Key:" + key)

    expiry_date = 604800  # 7 days

    try:
        create_presigned_url(bucket, key, expiry_date)
    except Exception as e:
        raise_error(e)


# -----------------------------------------------------------------------------
# Generate Pre-signed URL
# -----------------------------------------------------------------------------

def create_presigned_url(bucket_name, object_name, expiration=3600):
    """Generate a presigned URL to share an S3 object"""

    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3',
                             region_name='eu-west-1',
                             config=Config(signature_version='s3v4'))
    try:
        response = s3_client.generate_presigned_url('get_object',
                                                    Params={'Bucket': bucket_name,
                                                            'Key': object_name},
                                                    ExpiresIn=expiration,
                                                    HttpMethod='GET')
        logger.info("Pre-signed URL is " + response)
        msg_id = get_and_publish_sns_topic(response)
        logger.info("Message posted to Topic ARN with message ID: " + msg_id)
    except ClientError as e:
        logger.info(e)
        raise_error(e)


# -----------------------------------------------------------------------------
# Get SSN ARN and Publish the message to SNS Topic
# -----------------------------------------------------------------------------

def get_and_publish_sns_topic(message):
    """
    Lists topics for the current account.

    match the topic from the Environment Variable - TARGET_SNS_TOPIC

    Publish the Pre-signed URL to the Target SNS Topic

    :return: An iterator that yields the topics.
    """
    sns = boto3.client('sns', region_name='eu-west-1')

    try:
        sns_topic = os.environ['TARGET_SNS_TOPIC']
        if not sns_topic:
            raise_error('Target SNS Topic is not present')
    except ValueError as e:
        logger.info(e)
        raise_error(e)

    response1 = sns.list_topics()

    for each in response1['Topics']:
        topic = each['TopicArn']
        if (sns_topic == topic.split(':')[-1]):
            logger.info("Topic ARN Found " + topic)
            try:
                response = sns.publish(TopicArn=topic, Message=message)
                message_id = response['MessageId']
            except ClientError:
                raise_error("Unable to publish message to the SNS Topic " + topic)
            else:
                return message_id


# -----------------------------------------------------------------------------
# Raising Error
# -----------------------------------------------------------------------------

def raise_error(msg):
    """ Function to raise the Error and exit the Script process """

    print("ERROR:" + str(msg))
    logging.error(str(msg))
    slack_notify_error(msg)
    sys.exit(str(msg))


# -----------------------------------------------------------------------------
# Slack Notification of Error
# -----------------------------------------------------------------------------


def slack_notify_error(msg):
    """ Function notify the Errors in Slack Channel """

    env1 = os.environ['ENVIRONMENT']

    slack_url = os.environ['SLACK_WEBHOOK_SSM']

    error_input = (
            "Task name : MFT PyLambda Function  \n Environment: "
            + env1
            + " \n Error Message: Script Failure due to the error -"
            + msg
    )

    json_payload = '{"text": "' + error_input + '"}'

    if slack_url is not None:
        try:
            requests.post(slack_url, data=json_payload)
        except requests.RequestException as err:
            logging.error("HTTPS Post to Slack failed." + str(err))
