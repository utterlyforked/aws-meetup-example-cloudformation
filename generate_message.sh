#!/bin/bash

IFS=
MESSAGE=`fortune`

aws --profile=uf sqs send-message --queue-url=https://sqs.eu-west-1.amazonaws.com/680851172400/caas-sqs-WorkerQueue-1D7D5PCKOTWJJ --message-body=$MESSAGE
