import json
import boto3

ec2 = boto3.client(
    "ec2",
    endpoint_url="http://localhost.localstack.cloud:4566",
    region_name="us-east-1",
    aws_access_key_id="test",
    aws_secret_access_key="test"
)


def lambda_handler(event, context):
    path = event.get("path", "")
    params = event.get("queryStringParameters") or {}
    instance_id = params.get("instance_id")

    if not instance_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Paramètre 'instance_id' manquant"})
        }

    try:
        if "start" in path:
            ec2.start_instances(InstanceIds=[instance_id])
            message = f"Instance {instance_id} démarrée"
        elif "stop" in path:
            ec2.stop_instances(InstanceIds=[instance_id])
            message = f"Instance {instance_id} arrêtée"
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Action inconnue"})
            }

        return {
            "statusCode": 200,
            "body": json.dumps({"message": message, "instance_id": instance_id})
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
