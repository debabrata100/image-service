# Generate presign url:
```curl -X POST http://localhost:4566/restapis/<API_ID>/dev/_user_request_/presign \
-H "Content-Type: application/json" \
-d '{"fileName":"test.jpg"}'
```
# Upload using the URL you got from previous step
```
curl -X PUT "PASTE_UPLOAD_URL_HERE" \
-H "Content-Type: image/jpeg" \
--data-binary "@test.jpg"
```
# Verify in LocalStack S3
```aws --endpoint-url=http://localhost:4566 s3 ls s3://image-storage/```

# Upload to s3
```
aws \
  --endpoint-url=http://localhost:4566 \
  s3 cp \
  lambdas/upload-image/dist/lambda.zip \
  s3://image-service-artifacts/upload-image/lambda.zip

aws \
  --endpoint-url=http://localhost:4566 \
  s3 cp \
  lambdas/generate-presigned-url/dist/lambda.zip \
  s3://image-service-artifacts/generate-presigned-url/lambda.zip
```
# Check atrifacts
```
for all folders
aws \
  --endpoint-url=http://localhost:4566 \
  s3 ls s3://image-service-artifacts --recursive

for a single folder
aws \
  --endpoint-url=http://localhost:4566 \
  s3 ls s3://image-service-artifacts/generate-presigned-url --recursive
```