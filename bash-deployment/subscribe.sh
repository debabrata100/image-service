#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

TOPIC_ARN="arn:aws:sns:us-east-1:000000000000:$SNS_TOPIC_NAME"

QUEUE_URL=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  sqs get-queue-url \
  --queue-name "$SQS_QUEUE_NAME" \
  --query 'QueueUrl' \
  --output text)

QUEUE_ARN=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  sqs get-queue-attributes \
  --queue-url "$QUEUE_URL" \
  --attribute-names QueueArn \
  --query 'Attributes.QueueArn' \
  --output text)

EXISTING_SUB=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  sns list-subscriptions \
  --query "Subscriptions[?TopicArn=='$TOPIC_ARN' && Endpoint=='$QUEUE_ARN'].SubscriptionArn" \
  --output text)

if [ -n "$EXISTING_SUB" ] && [ "$EXISTING_SUB" != "None" ]; then
  echo "Subscription already exists"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    sns subscribe \
    --topic-arn "$TOPIC_ARN" \
    --protocol sqs \
    --notification-endpoint "$QUEUE_ARN"

  echo "Subscription created"
fi