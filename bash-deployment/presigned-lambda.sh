#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

echo "Ensuring Lambda exists: $PRESIGN_LAMBDA_FUNCTION_NAME"

EXISTS=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  lambda list-functions \
  --query "Functions[?FunctionName=='$PRESIGN_LAMBDA_FUNCTION_NAME'].FunctionName" \
  --output text)

if [ "$EXISTS" = "$PRESIGN_LAMBDA_FUNCTION_NAME" ]; then
  echo "Lambda already exists"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    lambda create-function \
    --function-name "$PRESIGN_LAMBDA_FUNCTION_NAME" \
    --runtime "$LAMBDA_RUNTIME" \
    --handler "$LAMBDA_HANDLER" \
    --role "$LAMBDA_ROLE" \
    --zip-file fileb://bootstrap/bootstrap.zip

  echo "Lambda created"
fi