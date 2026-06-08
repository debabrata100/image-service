# create s3 bucket
```awslocal s3 mb s3://image-storage```
# Verify
```awslocal s3 ls```
# Check objects inside s3 bucket
```awslocal s3 ls s3://image-storage```


# Create Lambda function
```awslocal lambda create-function \
  --function-name upload-image \
  --runtime nodejs20.x \
  --handler index.handler \
  --zip-file fileb://lambda.zip \
  --role arn:aws:iam::000000000000:role/lambda-role
  ```
# Lambda exist ?
```awslocal lambda list-functions```
# Check Lambda details
```awslocal lambda get-function \
  --function-name upload-image
  ```
# zip and upload lambda
```cd dist
zip lambda.zip index.js
```

# Update Lambda function
awslocal lambda update-function-code \
  --function-name upload-image \
  --zip-file fileb://lambda.zip


  # invoke lamda
 ``` awslocal lambda invoke \
  --function-name upload-image \
  --cli-binary-format raw-in-base64-out \
  --payload file://event.json \
  response.json

  cat response.json 
  ```
  event.json
  ```
  {
    "body":"{\"fileName\":\"hello.txt\",\"content\":\"Hello AWS\"}"
  }
```

  # check logs
  aws logs filter-log-events \
  --log-group-name /aws/lambda/upload-image \
  --endpoint-url=http://localhost:4566


  # API Gateway
  ```awslocal apigateway create-rest-api \
  --name image-api
  ```

  # GET current Api ID:
  ```aws \
  --endpoint-url=http://localhost:4566 \
  apigateway get-rest-apis
  ```

  ``` awslocal apigateway get-rest-apis ```
  export API_ID=abc123
  ``` awslocal apigateway get-resources \
  --rest-api-id $API_ID
  ```
  export ROOT_ID=xyz789
  --- Create /upload Resource ---
  ``` awslocal apigateway create-resource \
  --rest-api-id $API_ID \
  --parent-id $ROOT_ID \
  --path-part upload
  ```

  export UPLOAD_RESOURCE_ID=upload123
  ```
--- Verify ---
```awslocal apigateway get-resources \
  --rest-api-id $API_ID
  ```
--- Create POST Method ---
```
awslocal apigateway put-method \
  --rest-api-id $API_ID \
  --resource-id $UPLOAD_RESOURCE_ID \
  --http-method POST \
  --authorization-type NONE
  ```

--- Verify ---

```awslocal apigateway get-method \
  --rest-api-id $API_ID \
  --resource-id $UPLOAD_RESOURCE_ID \
  --http-method POST
```

--- Deploy APi gateway ---
```

awslocal apigateway create-deployment \
  --rest-api-id $API_ID \
  --stage-name dev

```  

--- Connect API Gateway to Lambda ---
First get Lambda ARN:
```
  awslocal lambda get-function \
  --function-name upload-image

  example:
  {
    "Configuration": {
      "FunctionArn": "arn:aws:lambda:us-east-1:000000000000:function:upload-image"
    }
  }
```
export LAMBDA_ARN=arn:aws:lambda:us-east-1:000000000000:function:upload-image
--- Now create integration: ---
```awslocal apigateway put-integration \
  --rest-api-id $API_ID \
  --resource-id $UPLOAD_RESOURCE_ID \
  --http-method POST \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LAMBDA_ARN/invocations
  ```

  # Invoke lambda through api gateway:
 ``` curl -X POST \
  http://localhost:4566/restapis/$API_ID/dev/_user_request_/upload \
  -H "Content-Type: application/json" \
  -d '{
    "fileName":"hello.txt",
    "content":"Hello AWS"
  }'
  ```

  # Logs
- logs tail:
```awslocal logs tail /aws/lambda/upload-image

or
aws \
  --endpoint-url=$AWS_ENDPOINT \
  logs tail /aws/lambda/upload-image
```
- watch logs in real-time?
```awslocal logs tail /aws/lambda/upload-image --follow```
- the last 10 lines
```awslocal logs tail /aws/lambda/upload-image --num-lines 10```
- By Events
```LATEST_STREAM=$(awslocal logs describe-log-streams \
  --log-group-name /aws/lambda/upload-image \
  --order-by LastEventTime \
  --descending \
  --limit 1 \
  --query "logStreams[0].logStreamName" \
  --output text)

awslocal logs get-log-events \
  --log-group-name /aws/lambda/upload-image \
  --log-stream-name "$LATEST_STREAM"
```

# Testing via curl
curl -X POST \
  -F "image=@cat.jpg" \
  http://localhost:4566/restapis/$API_ID/dev/_user_request_/upload

# Test via postman
```http://localhost:4566/restapis/<API_ID>/dev/_user_request_/upload```

# Create SNS Topic
```$ awslocal sns create-topic \
  --name image-uploaded

  $ awslocal sns list-topics
```

# Create a Subscription to verify using sqs
```
awslocal sqs create-queue \
  --queue-name image-upload-events
```
# Get the Queue ARN
```
awslocal sqs get-queue-attributes \
  --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/image-upload-events \
  --attribute-names QueueArn
```
# Subscribe sqs to sns
```
awslocal sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:000000000000:image-uploaded \
  --protocol sqs \
  --notification-endpoint arn:aws:sqs:us-east-1:000000000000:image-upload-events
```
# Test SNS → SQS directly (Publish a test message:)
```
awslocal sns publish \
  --topic-arn arn:aws:sns:us-east-1:000000000000:image-uploaded \
  --message '{"fileName":"test.jpg","size":12345}'
```
# Verify message reached to sqs
```
awslocal sqs receive-message \
  --queue-url http://sqs.us-east-1.localhost.localstack.cloud:4566/000000000000/image-upload-events
```