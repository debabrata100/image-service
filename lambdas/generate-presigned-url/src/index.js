const { S3Client, PutObjectCommand } = require("@aws-sdk/client-s3");
const { getSignedUrl } = require("@aws-sdk/s3-request-presigner");

const s3 = new S3Client({
  region: "us-east-1",
  endpoint: process.env.AWS_ENDPOINT || "http://localhost:4566",
  forcePathStyle: true,
});

exports.handler = async (event) => {
  const body = event.body ? JSON.parse(event.body) : {};
  const fileName = body.fileName || `file-${Date.now()}.jpg`;

  const bucket = process.env.BUCKET_NAME;

  const command = new PutObjectCommand({
    Bucket: bucket,
    Key: fileName,
    ContentType: "image/jpeg",
  });

  const url = await getSignedUrl(s3, command, { expiresIn: 300 });

  return {
    statusCode: 200,
    body: JSON.stringify({
      uploadUrl: url,
      fileName,
      version: "v2",
    }),
  };
};
