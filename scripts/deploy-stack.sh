#!/bin/bash

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./deploy-stack.sh v1"
  exit 1
fi

AWS_ENDPOINT="http://localhost:4566"

aws \
  --endpoint-url=$AWS_ENDPOINT \
  cloudformation deploy \
  --stack-name image-service \
  --template-file cloudformation/template.yaml \
  --parameter-overrides \
    UploadArtifactVersion=$VERSION \
    PresignArtifactVersion=$VERSION

echo "===== Stack Deployed ====="
echo "Version: $VERSION"
