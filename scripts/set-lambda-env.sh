#!/bin/bash

set -e

AWS_ENDPOINT="http://localhost:4566"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  lambda update-function-configuration \
  --function-name upload-image \
  --environment \
  "Variables={BUCKET_NAME=image-storage,TOPIC_ARN=arn:aws:sns:us-east-1:000000000000:image-uploaded}"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  lambda update-function-configuration \
  --function-name generate-presigned-url \
  --environment \
  "Variables={BUCKET_NAME=image-storage}"