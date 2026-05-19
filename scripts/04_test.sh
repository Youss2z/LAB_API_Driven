#!/bin/bash
API_ID=$(cat .api_id)
INSTANCE_ID=$(cat .instance_id)

echo "🧪 Tests"
echo "API ID      : $API_ID"
echo "Instance ID : $INSTANCE_ID"
echo ""

echo "📤 START..."
curl -s "http://localhost:4566/restapis/$API_ID/dev/_user_request_/start?instance_id=$INSTANCE_ID"
echo ""
sleep 2

echo "📤 STOP..."
curl -s "http://localhost:4566/restapis/$API_ID/dev/_user_request_/stop?instance_id=$INSTANCE_ID"
echo ""

echo "🔍 État :"
awslocal ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].[InstanceId,State.Name]' --output table
