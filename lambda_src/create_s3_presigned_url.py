import boto3
import logging
import os
import requests
import urllib.parse
from botocore.client import Config
from botocore.exceptions import ClientError

# Configure Logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# AWS Clients
S3_CLIENT = boto3.client('s3', region_name='eu-west-1', config=Config(signature_version='s3v4'))
SNS_CLIENT = boto3.client('sns', region_name='eu-west-1')


# -----------------------------------------------------------------------------
# This AWS Lambda function listens for S3 events, generates a pre-signed URL for accessing an object, and publishes
# it to an SNS topic. If any errors occur, it logs the issue and sends a Slack notification.
# -----------------------------------------------------------------------------
def lambda_handler(event, context):
    """ Entry point for the Lambda function. Processes S3 events and generates a pre-signed URL. """
    logger.info("Lambda function triggered.")

    try:
        # Extract bucket and object key from the event
        record = event.get('Records', [{}])[0].get('s3', {})
        bucket_name = record.get('bucket', {}).get('name')
        object_key = record.get('object', {}).get('key')

        if not bucket_name or not object_key:
            raise ValueError("Invalid S3 event structure. Missing bucket name or object key.")

        object_key = urllib.parse.unquote_plus(object_key, encoding='utf-8')
        logger.info(f"S3 Event received - Bucket: {bucket_name}, Key: {object_key}")

        # Generate and publish the pre-signed URL
        presigned_url = generate_presigned_url(bucket_name, object_key)
        if presigned_url:
            message_id = publish_to_sns(presigned_url)
            logger.info(f"Pre-signed URL published to SNS. Message ID: {message_id}")
        else:
            logger.warning("Failed to generate pre-signed URL.")

    except Exception as e:
        logger.error(f"Error processing S3 event: {str(e)}", exc_info=True)
        notify_slack_error(str(e))


# -----------------------------------------------------------------------------
# Generate Pre-signed URL
# -----------------------------------------------------------------------------
def generate_presigned_url(bucket_name, object_name, expiration=604800):
    """
    Generate a pre-signed URL to access an S3 object.
    :param bucket_name: S3 bucket name
    :param object_name: S3 object key
    :param expiration: URL expiration time in seconds (default: 7 days)
    :return: Pre-signed URL or None if an error occurs
    """
    try:
        presigned_url = S3_CLIENT.generate_presigned_url(
            'get_object',
            Params={'Bucket': bucket_name, 'Key': object_name},
            ExpiresIn=expiration,
            HttpMethod='GET'
        )
        logger.info(f"Generated Pre-signed URL: {presigned_url}")
        return presigned_url

    except ClientError as e:
        logger.error(f"Failed to generate pre-signed URL: {e}")
        return None


# -----------------------------------------------------------------------------
# Publish Message to SNS
# -----------------------------------------------------------------------------
def publish_to_sns(message):
    """
    Publish a pre-signed URL to an SNS Topic.
    :param message: Pre-signed URL message
    :return: Message ID if published successfully, None otherwise
    """
    try:
        sns_topic = os.getenv('TARGET_SNS_TOPIC')
        if not sns_topic:
            raise ValueError("Environment variable TARGET_SNS_TOPIC is not set.")

        response = SNS_CLIENT.publish(TopicArn=sns_topic, Message=message)
        return response.get('MessageId')

    except (ClientError, ValueError) as e:
        logger.error(f"Failed to publish message to SNS: {e}")
        return None


# -----------------------------------------------------------------------------
# Slack Notification for Errors
# -----------------------------------------------------------------------------
def notify_slack_error(error_message):
    """
    Sends an error notification to Slack.
    :param error_message: The error message to be sent
    """
    try:
        slack_webhook = os.getenv('SLACK_WEBHOOK_SSM')
        environment = os.getenv('ENVIRONMENT', 'unknown')

        if not slack_webhook:
            logger.warning("Slack webhook URL is not set. Skipping Slack notification.")
            return

        payload = {
            "text": f"*Error Notification* \n"
                    f"*Task:* MFT PyLambda Function\n"
                    f"*Environment:* {environment}\n"
                    f"*Error:* {error_message}"
        }

        response = requests.post(slack_webhook, json=payload)
        response.raise_for_status()
        logger.info("Slack notification sent successfully.")

    except requests.RequestException as err:
        logger.error(f"Failed to send Slack notification: {err}")