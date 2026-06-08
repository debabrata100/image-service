const parser = require("lambda-multipart-parser");
const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { SNSClient, PublishCommand } = require("@aws-sdk/client-sns");

const bucketName = process.env.BUCKET_NAME;
const topicArn = process.env.TOPIC_ARN;

const s3 = new S3Client({
  region: "us-east-1",
  endpoint: `http://${process.env.LOCALSTACK_HOSTNAME}:4566`,
  forcePathStyle: true,
  credentials: {
    accessKeyId: "test",
    secretAccessKey: "test",
  },
});

const sns = new SNSClient({
  region: "us-east-1",
  endpoint: `http://${process.env.LOCALSTACK_HOSTNAME}:4566`,
  credentials: {
    accessKeyId: "test",
    secretAccessKey: "test",
  },
});

exports.handler = async (event) => {
  const result = await parser.parse(event);

  const file = result.files[0];

  await s3.send(
    new PutObjectCommand({
      Bucket: bucketName,
      Key: file.filename,
      Body: file.content,
      ContentType: file.contentType,
    }),
  );

  console.log(
    JSON.stringify({
      event: "IMAGE_UPLOADED",
      fileName: file.filename,
      size: file.content.length,
      contentType: file.contentType,
    }),
  );

  await sns.send(
    new PublishCommand({
      TopicArn: topicArn,
      Message: JSON.stringify({
        fileName: file.filename,
        size: file.content.length,
        contentType: file.contentType,
      }),
    }),
  );

  return {
    statusCode: 200,
    body: JSON.stringify({
      uploaded: true,
      fileName: file.filename,
      version: "v2",
    }),
  };
};
