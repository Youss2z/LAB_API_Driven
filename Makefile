.PHONY: ec2 lambda api test deploy clean

ec2:
	@bash scripts/01_create_ec2.sh

lambda:
	@bash scripts/02_create_lambda.sh

api:
	@bash scripts/03_create_apigateway.sh

test:
	@bash scripts/04_test.sh

deploy: ec2 lambda api
	@echo "✅ Déploiement complet"

clean:
	@rm -f .instance_id .api_id function.zip
