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

# Update DNS resolver
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

# Create client credentials JSON
cat <<EOF > client_credentials.json
{
  "client_credentials": {
    "PDF_SERVICES_CLIENT_ID": "$ADOBE_CLIENT_ID",
    "PDF_SERVICES_CLIENT_SECRET": "$ADOBE_CLIENT_SECRET"
  }
}
EOF

cat client_credentials.json

# Store credentials in AWS Secrets Manager
if aws secretsmanager create-secret --name /myapp/client_credentials --description "Client credentials for PDF services" --secret-string file://client_credentials.json; then
    echo "Secret created successfully."
else
    aws secretsmanager update-secret --secret-id /myapp/client_credentials --description "Updated client credentials for PDF services" --secret-string file://client_credentials.json
    echo "Secret updated successfully."
fi

# Install Python dependencies
pip install -r requirements.txt
echo "Python dependencies installed successfully."

# Authenticate Docker with AWS ECR
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
echo "Docker authenticated with AWS ECR successfully."

# Deploy with AWS CDK
cdk deploy

# Keep the container running
/bin/bash
