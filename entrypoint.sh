#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Ensure script runs as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Restarting with sudo..."
    exec sudo "$0" "$@"
fi

# Start Docker daemon
echo "Starting Docker daemon..."
dockerd --storage-driver=fuse-overlayfs --iptables=false --bip=192.168.1.5/24 &

# Wait for Docker to be ready
echo "Waiting for Docker daemon to start..."
until docker info >/dev/null 2>&1; do
  sleep 2
done

echo "Docker is up and running!"

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

# Prompt for AWS credentials
read -p "Enter AWS Access Key ID: " AWS_ACCESS_KEY_ID
read -p "Enter AWS Secret Access Key: " AWS_SECRET_ACCESS_KEY
read -p "Enter AWS Region: " AWS_REGION
read -p "Enter AWS Account Number: " AWS_ACCOUNT_ID

# Prompt for Adobe Credentials
read -p "Enter Adobe Client ID: " ADOBE_CLIENT_ID
read -p "Enter Adobe Client Secret: " ADOBE_CLIENT_SECRET
echo "Adobe credentials captured."

# Configure AWS CLI
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_REGION"

echo "AWS configuration completed."

# Clone the repository
git clone --single-branch --branch deployment_dockerization https://github.com/ASUCICREPO/PDF_Accessibility.git
cd ./PDF_Accessibility

echo "Repository cloned successfully."

ls

JSON_TEMPLATE='{
  "client_credentials": {
    "PDF_SERVICES_CLIENT_ID": "<Your client ID here>",
    "PDF_SERVICES_CLIENT_SECRET": "<Your secret ID here>"
  }
}'

# Replace placeholders and store in a file
echo "$JSON_TEMPLATE" | jq --arg cid "$ADOBE_CLIENT_ID" --arg csec "$ADOBE_CLIENT_SECRET" \
    '.client_credentials.PDF_SERVICES_CLIENT_ID = $cid | 
     .client_credentials.PDF_SERVICES_CLIENT_SECRET = $csec' > client_credentials.json

cat client_credentials.json

if aws secretsmanager create-secret --name /myapp/client_credentials --description "Client credentials for PDF services" --secret-string file://client_credentials.json; then
    echo "Command create-secret succeeded"
else
    aws secretsmanager update-secret --secret-id /myapp/client_credentials --description "Updated client credentials for PDF services" --secret-string file://client_credentials.json
    echo "Command update-secret succeeded"
fi

pip install -r requirements.txt
echo "Command pip install requirements succeeded"

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com"
echo "Command get-login-password succeeded"

export BUILDX_NO_DEFAULT_ATTESTATIONS=1

cdk deploy


# # Install AWS CDK if not installed
# if ! command -v cdk &> /dev/null; then
#     echo "AWS CDK not found. Installing..."
#     npm install -g aws-cdk
# fi

# echo "AWS CDK installed."

# # Bootstrap CDK
# echo "Bootstrapping AWS CDK..."
# cdk bootstrap

# # Deploy the CDK stacks
# echo "Deploying infrastructure..."
# cdk deploy --require-approval never

# echo "Infrastructure deployed successfully."

# # Ensure Docker is installed inside the container
# if ! command -v docker &> /dev/null; then
#     echo "Docker not found. Installing Docker..."
#     apt update && apt install -y docker.io
# fi

# # Start Docker daemon
# service docker start

# echo "Docker installed and started successfully."

# # Build and push Docker images for both services
# echo "Building and pushing Docker images..."

# cd /app/autotag
# DOCKER_BUILDKIT=1 docker build -t your-ecr-repo/autotag:latest .
# aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin your-ecr-repo

# docker push your-ecr-repo/autotag:latest

# echo "Autotag image pushed."

# cd /app/javascript_docker
# DOCKER_BUILDKIT=1 docker build -t your-ecr-repo/javascript_docker:latest .
# docker push your-ecr-repo/javascript_docker:latest

# echo "Javascript Docker image pushed."

# echo "Deployment process completed successfully!"
