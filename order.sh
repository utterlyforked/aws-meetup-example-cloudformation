#!/bin/bash 

STACK_NAME=caas

echo "aws --profile=uf cloudformation create-stack --stack-name=$STACK_NAME-iam --template-body file://cfn-iam --capabilities=CAPABILITY_IAM"

InstanceRole="`aws --profile=uf cloudformation describe-stack-resource --stack-name=caas-iam --logical-resource-id=WorkerRole | jq -r '\"arn:aws:iam::680851172400:role/\" + .StackResourceDetail[\"PhysicalResourceId\"]'`"

InstanceProfile="`aws --profile=uf cloudformation describe-stack-resource --stack-name=caas-iam --logical-resource-id=WorkerRoleProfile | jq -r '.StackResourceDetail[\"PhysicalResourceId\"]'`"

echo "aws --profile=uf cloudformation create-stack --stack-name=$STACK_NAME-sqs  --template-body file://cfn-sqs --parameters=ParameterKey=InstanceProfile,ParameterValue=$InstanceRole"

SourceQueue="`aws --profile=uf cloudformation describe-stack-resource --stack-name=$STACK_NAME-sqs --logical-resource-id=WorkerQueue | jq -r '.StackResourceDetail[\"PhysicalResourceId\"]'`"

echo "aws --profile=uf cloudformation create-stack --stack-name=$STACK_NAME-s3  --template-body file://cfn-s3 --parameters=ParameterKey=InstanceProfile,ParameterValue=$InstanceRole"

TargetBucket="`aws --profile=uf cloudformation describe-stack-resource --stack-name=$STACK_NAME-s3 --logical-resource-id=S3Bucket | jq -r '.StackResourceDetail[\"PhysicalResourceId\"]'`"

echo "aws --profile=uf cloudformation create-stack --stack-name=$STACK_NAME-worker --template-body file://cfn-worker --parameters ParameterKey=SourceSQSQueue,ParameterValue=\"$SourceQueue\" ParameterKey=TargetS3Bucket,ParameterValue=\"$TargetBucket\" ParameterKey=InstanceProfile,ParameterValue=$InstanceProfile"

GroupToScale="`aws --profile=uf cloudformation describe-stack-resource --stack-name=$STACK_NAME-worker --logical-resource-id=WorkerAutoScalingGroup | jq -r '.StackResourceDetail[\"PhysicalResourceId\"]'`"

echo "aws --profile=uf cloudformation create-stack --stack-name=$STACK_NAME-cloudwatch --template-body file://cfn-cloudwatch --parameters ParameterKey=QueueToMonitor,ParameterValue=\"$SourceQueue\" ParameterKey=GroupToScale,ParameterValue=\"$GroupToScale\""
