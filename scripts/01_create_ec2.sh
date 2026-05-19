#!/bin/bash
echo "🚀 Création de l'instance EC2..."
# AMI Ubuntu 22.04 disponible dans LocalStack
AMI_ID="ami-df5de72bdb3b"

RESULT=$(awslocal ec2 run-instances --image-id $AMI_ID --instance-type t2.micro --count 1)
INSTANCE_ID=$(echo $RESULT | python3 -c "import sys, json; print(json.load(sys.stdin)['Instances'][0]['InstanceId'])")
echo "✅ Instance créée : $INSTANCE_ID"
echo $INSTANCE_ID > .instance_id
awslocal ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,State.Name]' --output table
