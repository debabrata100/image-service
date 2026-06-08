# Deploy

```
aws \
  --endpoint-url=http://localhost:4566 \
  cloudformation deploy \
  --stack-name image-service \
  --template-file cloudformation/template.yaml
```


# cloud formation describe stacks
```
aws --endpoint-url=http://localhost:4566 cloudformation describe-stacks \
  --stack-name image-service
```

# Inspect logs
```
docker logs <localstack container> -f
```