#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

FUNCTION_NAME="$PRESIGN_LAMBDA_FUNCTION_NAME"

echo "Building..."
cd lambdas/generate-presigned-url
pnpm build

echo "Packaging..."
pnpm package

echo "Deploying Lambda..."

aws \
  --endpoint-url=http://localhost:4566 \
  lambda update-function-code \
  --function-name "$FUNCTION_NAME" \
  --zip-file fileb://dist/lambda.zip

echo "Lambda deployed"