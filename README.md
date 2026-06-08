# Image Service

A serverless AWS image service that handles image uploads and presigned URL generation using Lambda, S3, SNS, and SQS.

## Overview

This project provides a complete image management solution on AWS with two main Lambda functions:

1. **Upload Image** - Receives multipart file uploads and stores them in S3, publishing events via SNS
2. **Generate Presigned URL** - Generates time-limited presigned URLs for direct S3 uploads

The service uses:
- **AWS Lambda** for serverless compute
- **Amazon S3** for image storage
- **Amazon SNS** for event notifications
- **Amazon SQS** for event queue processing
- **API Gateway** for HTTP endpoints

## Architecture

```
Client
  ├─→ Generate Presigned URL Lambda → S3 (returns signed URL)
  │
  └─→ Upload Image Lambda → S3 (stores image)
                          └→ SNS Topic (publishes event)
                             └→ SQS Queue (receives notification)
```

## Project Structure

```
image-service/
├── lambdas/
│   ├── generate-presigned-url/     # Presigned URL generation
│   │   ├── src/index.js
│   │   ├── package.json
│   │   └── pnpm-lock.yaml
│   └── upload-image/               # Image upload handler
│       ├── src/index.js
│       ├── bootstrap/index.js      # Lambda layer
│       ├── package.json
│       └── pnpm-lock.yaml
├── cloudformation/
│   ├── template.yaml               # Infrastructure as Code
│   └── readme.md
├── bash-deployment/                # Deployment scripts
│   ├── deploy-lambda.sh
│   ├── deploy-presigned-lambda.sh
│   ├── setup.sh
│   └── [other AWS CLI scripts]
├── scripts/
│   ├── build-and-upload.sh
│   ├── deploy-stack.sh
│   ├── release.sh
│   └── set-lambda-env.sh
└── README.md
```

## Prerequisites

- Node.js 20.x or higher
- pnpm (package manager)
- AWS CLI configured with appropriate credentials
- AWS SAM (Serverless Application Model) CLI
- Docker (for LocalStack testing)

## Setup

### 1. Install Dependencies

```bash
# Install dependencies for both Lambda functions
cd lambdas/upload-image
pnpm install
cd ../generate-presigned-url
pnpm install
cd ../..
```

### 2. Build Lambda Functions

```bash
# Build upload-image
cd lambdas/upload-image
pnpm run build
pnpm run package
cd ../..

# Build generate-presigned-url
cd lambdas/generate-presigned-url
pnpm run build
pnpm run package
cd ../..
```

### 3. Deploy Infrastructure

Using CloudFormation template:

```bash
# Deploy the CloudFormation stack
aws cloudformation deploy \
  --template-file cloudformation/template.yaml \
  --stack-name image-service-stack \
  --capabilities CAPABILITY_NAMED_IAM
```

Or using provided deployment scripts:

```bash
# Set up AWS resources
./bash-deployment/setup.sh

# Deploy Lambda functions
./bash-deployment/deploy-lambda.sh
./bash-deployment/deploy-presigned-lambda.sh

# Deploy the full stack
./scripts/deploy-stack.sh
```

## Usage

### Generate Presigned URL

Send a POST request to get a presigned URL for uploading an image:

```bash
curl -X POST https://your-api-endpoint/presigned \
  -H "Content-Type: application/json" \
  -d '{"fileName":"my-image.jpg"}'
```

Response:
```json
{
  "uploadUrl": "https://image-storage.s3.amazonaws.com/...",
  "fileName": "my-image.jpg",
  "version": "v2"
}
```

The presigned URL is valid for 5 minutes.

### Upload Image

Upload an image directly using the presigned URL:

```bash
curl -X PUT "https://image-storage.s3.amazonaws.com/..." \
  -H "Content-Type: image/jpeg" \
  --data-binary @myimage.jpg
```

Or use the upload endpoint:

```bash
curl -X POST https://your-api-endpoint/upload \
  -F "file=@myimage.jpg"
```

The service will:
1. Store the image in S3
2. Publish an event to the SNS topic
3. Log upload details

## Environment Variables

Configure these environment variables for Lambda functions:

- `BUCKET_NAME` - S3 bucket name for image storage
- `TOPIC_ARN` - SNS topic ARN for upload notifications
- `LOCALSTACK_HOSTNAME` - LocalStack endpoint (for local testing)
- `AWS_ENDPOINT` - AWS endpoint URL (for local testing)

## Testing Locally

### With LocalStack

```bash
# Start LocalStack
docker-compose up -d localstack

# Set environment for local testing
export AWS_ENDPOINT=http://localhost:4566
export LOCALSTACK_HOSTNAME=localhost

# Deploy to LocalStack
./scripts/deploy-stack.sh
```

## Development

### Building

Each Lambda function uses esbuild for bundling:

```bash
cd lambdas/[lambda-name]
pnpm run build      # Compile TypeScript/JavaScript
pnpm run package    # Create deployment zip
```

### Scripts

- `scripts/build-and-upload.sh` - Build and upload Lambda artifacts to S3
- `scripts/deploy-stack.sh` - Deploy CloudFormation stack
- `scripts/set-lambda-env.sh` - Configure Lambda environment variables
- `scripts/release.sh` - Full release workflow

## AWS Resources Created

The CloudFormation template creates:

- **S3 Bucket** (`image-storage`) - Image storage
- **SNS Topic** (`image-uploaded`) - Upload notifications
- **SQS Queue** (`image-upload-events`) - Event queue
- **Lambda Functions**
  - `upload-image` - Handles file uploads
  - `generate-presigned-url` - Generates presigned URLs
- **IAM Role** - Lambda execution permissions

## Monitoring

Lambda functions log to CloudWatch:

```bash
# View upload-image logs
aws logs tail /aws/lambda/upload-image --follow

# View presigned-url logs
aws logs tail /aws/lambda/generate-presigned-url --follow
```

## Cleanup

Remove AWS resources:

```bash
# Delete CloudFormation stack
aws cloudformation delete-stack --stack-name image-service-stack

# Or manually delete resources
aws s3 rb s3://image-storage --force
aws sns delete-topic --topic-arn arn:aws:sns:us-east-1:YOUR_ACCOUNT:image-uploaded
aws sqs delete-queue --queue-url https://sqs.us-east-1.amazonaws.com/YOUR_ACCOUNT/image-upload-events
```

## Dependencies

### Runtime Dependencies
- `@aws-sdk/client-s3` - AWS S3 client
- `@aws-sdk/client-sns` - AWS SNS client
- `@aws-sdk/s3-request-presigner` - Presigned URL generation
- `lambda-multipart-parser` - Multipart form parsing

### Dev Dependencies
- `esbuild` - JavaScript bundler

## License

ISC

## Author
Deb
