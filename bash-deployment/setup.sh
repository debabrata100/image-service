#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "===== Infrastructure Setup ====="

"$SCRIPT_DIR/s3.sh"
"$SCRIPT_DIR/sns.sh"
"$SCRIPT_DIR/sqs.sh"
"$SCRIPT_DIR/subscribe.sh"
"$SCRIPT_DIR/lambda.sh"
"$SCRIPT_DIR/apigateway.sh"
echo "===== Setup Complete ====="