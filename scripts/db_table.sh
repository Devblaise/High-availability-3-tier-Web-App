#!/bin/bash

# Check if the DynamoDB table already exists
    - aws configure set region eu-west-2
    - |
      TABLE_EXISTS=$(aws dynamodb describe-table --table-name three-tier-tf-lock 2>&1 || echo "not found")
      if [[ "$TABLE_EXISTS" == *"not found"* ]]; then
        echo "Table does not exist, creating it..."
        aws dynamodb create-table \
          --table-name three-tier-tf-lock \
          --attribute-definitions AttributeName=LockID,AttributeType=S \
          --key-schema AttributeName=LockID,KeyType=HASH \
          --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
      else
        echo "Table already exists, skipping creation."
      fi
