#!/bin/bash

source ./setup-scripts/functions-util.sh

echo 'Configuring AWS CLI'

printloc

if [ -z ${AWS_OUTPUT+x} ]; then
    echo "Skipping AWS_OUTPUT"
else
    echo 'Configuring AWS_OUTPUT'
    aws configure set default.output $AWS_OUTPUT && echo "  SUCCESS" || echo "  ERROR"
fi
if [ -z ${AWS_REGION+x} ]; then
    echo "Skipping AWS_REGION"
else
    echo 'Configuring AWS_REGION'
    aws configure set default.region $AWS_REGION && echo "  SUCCESS" || echo "  ERROR"
fi
if [ -z ${AWS_ACCESS_KEY+x} ]; then
    echo "Skipping AWS_ACCESS_KEY"
else
    echo 'Configuring AWS_ACCESS_KEY'
    aws configure set default.aws_access_key_id $AWS_ACCESS_KEY && echo "  SUCCESS" || echo "  ERROR"
fi
if [ -z ${AWS_SECRET_KEY+x} ]; then
    echo "Skipping AWS_SECRET_KEY"
else
    echo 'Configuring AWS_SECRET_KEY'
    aws configure set default.aws_secret_access_key $AWS_SECRET_KEY && echo "  SUCCESS" || echo "  ERROR"
fi

if [ "$VERBOSE" = true ]; then aws configure list; fi
