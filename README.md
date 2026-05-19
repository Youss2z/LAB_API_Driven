# ATELIER API-DRIVEN INFRASTRUCTURE

Architecture serverless permettant de piloter des instances EC2 via **API Gateway** et **Lambda**, dans un environnement AWS simulé avec **LocalStack** et exécuté depuis **GitHub Codespaces**.

## Architecture

curl  →  API Gateway  →  Lambda  →  EC2 (start/stop)

Une requête HTTP `GET /start?instance_id=i-xxx` passe par l’API Gateway puis déclenche la fonction Lambda `ec2_controller`, qui utilise boto3 afin de démarrer ou arrêter une instance EC2 dans LocalStack.

## Prérequis

- **GitHub Codespaces** (recommandé)
- Compte gratuit sur [app.localstack.cloud](https://app.localstack.cloud) afin d’obtenir un Auth Token

## Installation

### 1. Démarrer LocalStack

    pip install localstack awscli awscli-local
    localstack auth set-token VOTRE_TOKEN
    localstack start -d

Vérifier que LocalStack fonctionne correctement :

    docker ps

Le conteneur `localstack-main` doit apparaître avec l’état "healthy".

### 2. Configuration AWS CLI

    aws configure

- Access Key : test
- Secret Key : test
- Region     : us-east-1
- Format     : json

### 3. Déploiement complet de l’infrastructure

    make deploy

Cette commande réalise automatiquement :

1. Création d’une instance EC2 (`scripts/01_create_ec2.sh`)
2. Déploiement de la fonction Lambda (`scripts/02_create_lambda.sh`)
3. Création de l’API Gateway avec les routes `/start` et `/stop` (`scripts/03_create_apigateway.sh`)

### 4. Vérification

    make test

Le test effectue automatiquement un appel `/start` puis `/stop` et affiche ensuite l’état final de l’instance.

## Test manuel avec curl

    API_ID=$(cat .api_id)
    INSTANCE_ID=$(cat .instance_id)

    curl "http://localhost:4566/restapis/$API_ID/dev/_user_request_/start?instance_id=$INSTANCE_ID"

    curl "http://localhost:4566/restapis/$API_ID/dev/_user_request_/stop?instance_id=$INSTANCE_ID"

## Structure du projet

- `lambda/ec2_controller.py` : Fonction Lambda utilisant boto3
- `scripts/01_create_ec2.sh` : Création de l’instance EC2
- `scripts/02_create_lambda.sh` : Déploiement de la fonction Lambda
- `scripts/03_create_apigateway.sh` : Configuration de l’API Gateway
- `scripts/04_test.sh` : Tests automatisés
- `Makefile` : Automatisation du déploiement
- `README.md`

## 🔧 Commandes Makefile

| Commande | Action |
|---|---|
| make ec2 | Création d’une instance EC2 |
| make lambda | Déploiement de la fonction Lambda |
| make api | Création de l’API Gateway |
| make deploy | Déploiement complet (EC2 + Lambda + API) |
| make test | Lancement des tests start/stop |
| make clean | Suppression des fichiers temporaires |

## Choix techniques

- **LocalStack** : permet de simuler AWS localement sans coût supplémentaire
- **awscli-local (awslocal)** : wrapper qui redirige automatiquement vers `http://localhost:4566`
- **AWS_PROXY** : intégration directe entre API Gateway et Lambda sans transformation des requêtes
- **localhost.localstack.cloud** : DNS interne utilisé par la Lambda pour communiquer avec EC2
- **Makefile** : simplifie entièrement le déploiement avec une seule commande

## Exemple de sortie

    📤 START...
    {"message": "Instance i-9e523de685f3e0d9f démarrée"}

    📤 STOP...
    {"message": "Instance i-9e523de685f3e0d9f arrêtée"}

    🔍 État : stopped

## Dépannage

### Internal server error sur les appels API

La fonction Lambda ne parvient pas à joindre EC2. Vérifier que l’endpoint dans `lambda/ec2_controller.py` est bien :

    http://localhost.localstack.cloud:4566

### InvalidAMIID.NotFound

Lister les AMIs disponibles avec :

    awslocal ec2 describe-images

Puis mettre à jour `AMI_ID` dans `scripts/01_create_ec2.sh`.

### could not connect to LocalStack

LocalStack peut mettre plusieurs secondes avant d’être totalement opérationnel. Vérifier avec :

    docker ps

que le conteneur est bien en état "healthy".

## Auteur

Atelier réalisé par HUSSEIN Youssef dans le cadre du module Cloud / DevOps.
