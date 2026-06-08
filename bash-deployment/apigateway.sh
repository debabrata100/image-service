#!/bin/bash

set -e

source "$(dirname "$0")/config.sh"

echo "Ensuring API Gateway exists: $API_NAME"

API_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-rest-apis \
  --query "items[?name=='$API_NAME'].id" \
  --output text)

if [ -n "$API_ID" ] && [ "$API_ID" != "None" ]; then
  echo "API already exists: $API_ID"
else
  API_ID=$(aws \
    --endpoint-url=$AWS_ENDPOINT \
    apigateway create-rest-api \
    --name "$API_NAME" \
    --query id \
    --output text)

  echo "API created: $API_ID"
fi

ROOT_RESOURCE_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/'].id" \
  --output text)

RESOURCE_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/$API_RESOURCE_PATH'].id" \
  --output text)

if [ -n "$RESOURCE_ID" ] && [ "$RESOURCE_ID" != "None" ]; then
  echo "Resource already exists: /$API_RESOURCE_PATH"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$ROOT_RESOURCE_ID" \
    --path-part "$API_RESOURCE_PATH" >/dev/null

  echo "Resource created: /$API_RESOURCE_PATH"
fi
# presigned resource id
PRESIGN_RESOURCE_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/$PRESIGN_RESOURCE_PATH'].id" \
  --output text)

PRESIGN_RESOURCE_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/$PRESIGN_RESOURCE_PATH'].id" \
  --output text)

if [ -n "$PRESIGN_RESOURCE_ID" ] && [ "$PRESIGN_RESOURCE_ID" != "None" ]; then
  echo "Resource already exists: /$PRESIGN_RESOURCE_PATH"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    apigateway create-resource \
    --rest-api-id "$API_ID" \
    --parent-id "$ROOT_RESOURCE_ID" \
    --path-part "$PRESIGN_RESOURCE_PATH" >/dev/null

  echo "Resource created: /$PRESIGN_RESOURCE_PATH"
fi

PRESIGN_RESOURCE_ID=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resources \
  --rest-api-id "$API_ID" \
  --query "items[?path=='/$PRESIGN_RESOURCE_PATH'].id" \
  --output text)

METHOD_EXISTS=$(aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway get-resource \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --query "resourceMethods.POST.httpMethod" \
  --output text 2>/dev/null || true)

if [ "$METHOD_EXISTS" = "POST" ]; then
  echo "POST method already exists"
else
  aws \
    --endpoint-url=$AWS_ENDPOINT \
    apigateway put-method \
    --rest-api-id "$API_ID" \
    --resource-id "$RESOURCE_ID" \
    --http-method POST \
    --authorization-type NONE >/dev/null

  echo "POST method created"
fi

INTEGRATION_URI="arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:$LAMBDA_FUNCTION_NAME/invocations"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$RESOURCE_ID" \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "$INTEGRATION_URI" >/dev/null

echo "Lambda integration configured"

echo "Deploying API..."

aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name dev >/dev/null

echo "API deployed to stage: dev"

PRESIGN_INTEGRATION_URI="arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:$PRESIGN_LAMBDA_FUNCTION_NAME/invocations"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway put-method \
  --rest-api-id "$API_ID" \
  --resource-id "$PRESIGN_RESOURCE_ID" \
  --http-method POST \
  --authorization-type NONE

aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway put-integration \
  --rest-api-id "$API_ID" \
  --resource-id "$PRESIGN_RESOURCE_ID" \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "$PRESIGN_INTEGRATION_URI"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  apigateway create-deployment \
  --rest-api-id "$API_ID" \
  --stage-name dev

echo "Presigned URL API deployed to stage: dev"