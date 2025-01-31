#!/bin/bash
LAMBDA_CONTAINER_ID_FILE="/tmp/docker_tdmp_aws_lambda.cid"
LAMBDA_PYTHON_DEPENDENCIES_ZIP="/code/$LAMBDA_PYTHON_DEPENDENCIES_ZIP_NAME"

rm -rf "$LAMBDA_CONTAINER_ID_FILE"
docker build --no-cache -t tdmp-aws-lambda-test .
docker run --cidfile "$LAMBDA_CONTAINER_ID_FILE" -d tdmp-aws-lambda-test
DOCKER_TDMP_AWS_LAMBDA_CID=$(cat "$LAMBDA_CONTAINER_ID_FILE")
docker cp "$DOCKER_TDMP_AWS_LAMBDA_CID:$LAMBDA_PYTHON_DEPENDENCIES_ZIP" .
docker stop "$DOCKER_TDMP_AWS_LAMBDA_CID"
docker rm "$DOCKER_TDMP_AWS_LAMBDA_CID"
