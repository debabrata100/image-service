#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

echo "Ensuring SNS topic exists: $SNS_TOPIC_NAME"

TOPIC_ARN=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  sns create-topic \
  --name "$SNS_TOPIC_NAME" \
  --query 'TopicArn' \
  --output text)

echo "Topic ARN: $TOPIC_ARN"