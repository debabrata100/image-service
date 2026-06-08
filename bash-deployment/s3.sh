#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

echo "Ensuring S3 bucket exists: $BUCKET_NAME"

if aws --endpoint-url=$AWS_ENDPOINT s3 ls "s3://$BUCKET_NAME" >/dev/null 2>&1; then
  echo "Bucket already exists"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    s3 mb "s3://$BUCKET_NAME"

  echo "Bucket created"
fi