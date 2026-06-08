#!/bin/bash

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./build-and-upload.sh v1"
  exit 1
fi

ARTIFACT_BUCKET="image-service-artifacts"
AWS_ENDPOINT="http://localhost:4566"

echo "===== Building upload-image ====="

cd lambdas/upload-image
pnpm build
pnpm package

aws \
  --endpoint-url=$AWS_ENDPOINT \
  s3 cp \
  dist/lambda.zip \
  s3://$ARTIFACT_BUCKET/upload-image/lambda-${VERSION}.zip

cd ../..

echo "===== Building generate-presigned-url ====="

cd lambdas/generate-presigned-url
pnpm build
pnpm package

aws \
  --endpoint-url=$AWS_ENDPOINT \
  s3 cp \
  dist/lambda.zip \
  s3://$ARTIFACT_BUCKET/generate-presigned-url/lambda-${VERSION}.zip

cd ../..

echo "===== Upload Complete ====="

echo "Version: $VERSION"