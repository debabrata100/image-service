#!/bin/bash

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
  echo "Usage: ./scripts/release.sh v1"
  exit 1
fi

echo "================================="
echo "Releasing Version: $VERSION"
echo "================================="

echo ""
echo "Step 1: Build and Upload Artifacts"
./scripts/build-and-upload.sh "$VERSION"

echo ""
echo "Step 2: Deploy CloudFormation Stack"
./scripts/deploy-stack.sh "$VERSION"

echo ""
echo "Step 3: Configure Lambda Environment Variables"
./scripts/set-lambda-env.sh

echo ""
echo "================================="
echo "Release Complete: $VERSION"
echo "================================="