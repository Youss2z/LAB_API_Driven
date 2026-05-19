#!/bin/bash
echo "🌐 Création de l'API Gateway..."

API_ID=$(awslocal apigateway create-rest-api --name "EC2ControllerAPI" --query 'id' --output text)
echo "API ID : $API_ID"

ROOT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query 'items[0].id' --output text)

START_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $ROOT_ID --path-part "start" --query 'id' --output text)
STOP_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $ROOT_ID --path-part "stop" --query 'id' --output text)

for RES_ID in $START_ID $STOP_ID; do
    awslocal apigateway put-method --rest-api-id $API_ID --resource-id $RES_ID --http-method GET --authorization-type "NONE"
    awslocal apigateway put-integration --rest-api-id $API_ID --resource-id $RES_ID --http-method GET --type AWS_PROXY --integration-http-method POST --uri "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:000000000000:function:ec2_controller/invocations"
done

awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name dev
echo $API_ID > .api_id

echo ""
echo "✅ API Gateway créée !"
echo "URLs :"
echo "  START : http://localhost:4566/restapis/$API_ID/dev/_user_request_/start?instance_id=XXX"
echo "  STOP  : http://localhost:4566/restapis/$API_ID/dev/_user_request_/stop?instance_id=XXX"
