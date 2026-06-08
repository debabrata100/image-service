#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

echo "Ensuring SQS queue exists: $SQS_QUEUE_NAME"

QUEUE_URL=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  sqs create-queue \
  --queue-name "$SQS_QUEUE_NAME" \
  --query 'QueueUrl' \
  --output text)

echo "Queue URL: $QUEUE_URL"