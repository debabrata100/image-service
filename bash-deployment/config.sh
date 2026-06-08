#!/bin/bash

export AWS_ENDPOINT="http://localhost:4566"

export BUCKET_NAME="image-storage"
export SNS_TOPIC_NAME="image-uploaded"
export SQS_QUEUE_NAME="image-upload-events"
export LAMBDA_FUNCTION_NAME="upload-image"
export LAMBDA_HANDLER="index.handler"
export LAMBDA_RUNTIME="nodejs20.x"
export LAMBDA_ROLE="arn:aws:iam::000000000000:role/lambda-role"
export API_NAME="image-api"
export API_RESOURCE_PATH="upload"
export PRESIGN_RESOURCE_PATH="presign"
export PRESIGN_LAMBDA_FUNCTION_NAME="generate-presigned-url"