#!/bin/bash
echo "📦 Création du package Lambda..."
cd lambda && zip -r ../function.zip ec2_controller.py && cd ..

echo "🔧 Déploiement de la Lambda..."
awslocal lambda delete-function --function-name ec2_controller 2>/dev/null

awslocal lambda create-function \
    --function-name ec2_controller \
    --runtime python3.11 \
    --handler ec2_controller.lambda_handler \
    --zip-file fileb://function.zip \
    --role arn:aws:iam::000000000000:role/lambda-role

echo "✅ Lambda déployée"
rm function.zip
