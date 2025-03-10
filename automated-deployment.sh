#!/bin/bash
# This script:
# 1. Prompts for the GitHub repo URL, CodeBuild project name,
#    Docker username, and Docker password.
# 2. Checks for (or creates) an IAM service role for CodeBuild.
# 3. Creates a CodeBuild project using the "code-deploy-automation" branch.
#    It passes the Docker credentials as environment variables.
# 4. Starts a build of the project and then lists the projects before exiting.

# Prompt for the GitHub repository URL (repository URL without branch appended)
read -p "Enter the GitHub repository URL (e.g., https://github.com/ASUCICREPO/PDF_Accessibility): " GITHUB_URL

# Prompt for a CodeBuild project name
read -p "Enter the CodeBuild project name: " PROJECT_NAME

# Prompt for Docker credentials
read -p "Enter your Docker username: " DOCKER_USERNAME
read -s -p "Enter your Docker password: " DOCKER_PASSWORD
echo ""

# Define a name for the IAM service role
ROLE_NAME="${PROJECT_NAME}-codebuild-service-role"

echo "Checking if IAM role '$ROLE_NAME' exists..."
if aws iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  echo "Role '$ROLE_NAME' exists. Using the existing role."
  ROLE_ARN=$(aws iam get-role --role-name "$ROLE_NAME" --output json | jq -r '.Role.Arn')
else
  echo "Role '$ROLE_NAME' does not exist. Creating it now..."
  # Create a trust policy for CodeBuild
  TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  )

  CREATE_ROLE_OUTPUT=$(aws iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "$TRUST_POLICY" \
    --output json)

  if [ $? -ne 0 ]; then
    echo "Error: Failed to create IAM role."
    exit 1
  fi

  ROLE_ARN=$(echo "$CREATE_ROLE_OUTPUT" | jq -r '.Role.Arn')
  echo "Role created with ARN: $ROLE_ARN"

  echo "Attaching AdministratorAccess policy to role..."
  aws iam attach-role-policy --role-name "$ROLE_NAME" --policy-arn "arn:aws:iam::aws:policy/AdministratorAccess"

  if [ $? -ne 0 ]; then
    echo "Error: Failed to attach AdministratorAccess policy."
    exit 1
  fi

  echo "Waiting a few seconds for role propagation..."
  sleep 10
fi

# Define the build environment settings using the amazonlinux-x86_64-standard:5.0 image
# and add Docker credentials as environment variables.
ENVIRONMENT=$(cat <<EOF
{
  "type": "LINUX_CONTAINER",
  "image": "aws/codebuild/amazonlinux-x86_64-standard:5.0",
  "computeType": "BUILD_GENERAL1_SMALL",
  "environmentVariables": [
    {
      "name": "DOCKER_USERNAME",
      "value": "$DOCKER_USERNAME",
      "type": "PLAINTEXT"
    },
    {
      "name": "DOCKER_PASSWORD",
      "value": "$DOCKER_PASSWORD",
      "type": "PLAINTEXT"
    }
  ]
}
EOF
)

# Define the artifacts configuration (NO_ARTIFACTS in this example)
ARTIFACTS='{"type": "NO_ARTIFACTS"}'

# Create the source configuration JSON.
# Use the repository URL without branch appended.
SOURCE='{"type": "GITHUB", "location": "'"$GITHUB_URL"'"}'

# Specify the source version (branch) to use.
SOURCE_VERSION="code-deploy-automation"

echo "Creating CodeBuild project '$PROJECT_NAME' using branch '$SOURCE_VERSION' ..."
aws codebuild create-project \
  --name "$PROJECT_NAME" \
  --source "$SOURCE" \
  --source-version "$SOURCE_VERSION" \
  --artifacts "$ARTIFACTS" \
  --environment "$ENVIRONMENT" \
  --service-role "$ROLE_ARN" \
  --output json

if [ $? -eq 0 ]; then
    echo "CodeBuild project '$PROJECT_NAME' created successfully."
else
    echo "Failed to create CodeBuild project. Please check your AWS CLI configuration and parameters."
    exit 1
fi

echo "Starting a build for project '$PROJECT_NAME' ..."
aws codebuild start-build --project-name "$PROJECT_NAME" --output json

if [ $? -eq 0 ]; then
    echo "Build started successfully."
else
    echo "Failed to start the build."
    exit 1
fi

echo "Listing CodeBuild projects:"
aws codebuild list-projects --output table

exit 0
