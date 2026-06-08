```
chmod +x scripts/setup.sh

localstack start

./scripts/setup.sh
./scripts/deploy-lambda.sh

```
# Verify S3 bucket exists
```aws \
  --endpoint-url=http://localhost:4566 \
  s3 ls
```
# Verify SNS topic exists
```
aws \
  --endpoint-url=http://localhost:4566 \
  sns list-topics
```
# Verify SQS queue exists
```
aws \
  --endpoint-url=http://localhost:4566 \
  sqs list-queues
```
# Verify Lambda exists
```
aws \
  --endpoint-url=http://localhost:4566 \
  lambda list-functions
```
# Verify API Gateway exists
```
aws \
  --endpoint-url=http://localhost:4566 \
  apigateway get-rest-apis
```
# Verify API Gateway stage exists
```
aws \
  --endpoint-url=http://localhost:4566 \
  apigateway get-stages \
  --rest-api-id <API_ID>
```
# postman test
http://localhost:4566/restapis/<API_ID>/dev/_user_request_/upload




# Automated LocalStack setup
setup.sh
│
├── S3 Bucket
├── SNS Topic
├── SQS Queue
├── SNS → SQS Subscription
├── Lambda
├── API Gateway
│    ├── /upload
│    ├── POST
│    ├── Lambda Integration
│    └── dev Stage Deployment
│
└── Ready to use