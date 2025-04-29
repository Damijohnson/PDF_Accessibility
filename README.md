# PDF Processing AWS Infrastructure

This project builds an AWS infrastructure using AWS CDK (Cloud Development Kit) to split a PDF into chunks, process the chunks via AWS Step Functions, and merge the resulting chunks back using ECS tasks. The infrastructure also includes monitoring via CloudWatch dashboards and metrics for tracking progress.

## Prerequisites

Before running the AWS CDK stack, ensure the following are installed and configured:

1. **AWS Bedrock Access**: Ensure your AWS account has access to the Nova pro model in Amazon Bedrock.
   - [Request access to Amazon Bedrock](https://console.aws.amazon.com/bedrock/) through the AWS console if not already enabled.

2. **Adobe API Access** - An enterprise-level contract or a trial account (For Testing) for Adobe's API is required.

   - [Adobe PDF Services API](https://acrobatservices.adobe.com/dc-integration-creation-app-cdn/main.html) to obtain API credentials.
  
3. **Docker**: Required to build and run Docker images for the ECS tasks.  
   - [Install Docker](https://docs.docker.com/get-docker/)  
   - Verify installation:  
     ```bash
     docker --version
     ```

4. **AWS Account Permissions**  
   - Ensure permissions to create and manage AWS resources like S3, Lambda, ECS, ECR, Step Functions, and CloudWatch.  
   - [AWS IAM Policies and Permissions](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html)
   - Also, For the ease of deployment. Create a IAM user in the account you want to deploy to and attach adminstrator access to that user and use the Access key and Secret key for that user.

## Directory Structure

Ensure your project has the following structure:

```
├── app.py (Main CDK app)
├── lambda/
│   ├── split_pdf/ (Python Lambda for splitting PDF)
│   └── java_lambda/ (Java Lambda for merging PDFs)
├── docker_autotag/ (Python Docker image for ECS task)
└── javascript_docker/ (JavaScript Docker image for ECS task)
|__ client_credentials.json (The client id and client secret id for adobe)
|__ docker-compose.yml (Docker Compose file)
|__ dockerfile (Dockerfile for the CDK deployer)
|__ deploy.sh (Shell script for deployment)
```

## Setup and Deployment

1. **Clone the Repository**:
   - Clone this repository containing the CDK code, Docker configurations, and Lambda functions.
     
2. **Download Docker**:
   - Make sure you have docker installed on your system (you can find out more here about how to download the docker on your system: https://www.docker.com/products/docker-desktop/)
     
3. **Run the Commands Below**:
  a. Docker Build
   - If you are on windows, Run:
    `$env:BUILDX_NO_DEFAULT_ATTESTATIONS = "1" ; docker-compose build --no-cache in the root directory of the project`
   - If you are on MAC, Run:
     `Run export BUILDX_NO_DEFAULT_ATTESTATIONS=1; docker-compose build --no-cache in the root directory of the project`
  b. Docker Run
      `docker-compose run cdk-deployer`

     
4. **Enter Required Credentials and Other Configuration Information**:
   - You will be prompted to enter the following information:
      - AWS Access Key ID
      - AWS Secret Access Key
      - AWS Account ID
      - AWS Region (e.g., us-east-1)
      - Adobe Client ID
      - Adobe Client Secret

## Usage

Once the infrastructure is deployed:

1. Create a `pdf/` folder in the S3 bucket created by the CDK stack.
2. Upload a PDF file to the `pdf/` folder in the S3 bucket.
3. The process will automatically trigger and start processing the PDF.

## Monitoring

- Use the CloudWatch dashboards created by the stack to monitor the progress and performance of the PDF processing pipeline.

## Limitations

- This solution does not remediate corrupted PDFs.

- It can process scanned PDFs, but the output accuracy is approximately 80%.

- It does not remediate fillable forms.

- It does not handle color selection/contrast adjustments.


## Troubleshooting

If you encounter any issues during setup or deployment, please check the following:

- Ensure all prerequisites are correctly installed and configured.
- Verify that your AWS credentials have the necessary permissions.
- Check CloudWatch logs for any error messages in the Lambda functions or ECS tasks. 
- If the CDK Deploy responds with: ` Python was not found; run without arguments to install from the Microsoft Store, or disable this shortcut from Settings > Manage App Execution Aliases.
Subprocess exited with error 9009 `, try changing ` "app": "python3 app.py" ` to  ` "app": "python app.py" ` in the cdk.json file
- If the CDK deploy responds with: ` Resource handler returned message: "The maximum number of addresses has been reached. ` request additional IPs from AWS. Go to https://us-east-1.console.aws.amazon.com/servicequotas/home/services/ec2/quotas and search for "IP". Then, choose "EC2-VPC Elastic IPs". Note the AWS region is included in the URL, change it to the region you are deploying into. Requests for additional IPs are usually completed within minutes.
- If any Docker images are not pushing to ECR, manually deploy to ECR using the push commands provided in the ECR console. Then, manually update the ECS service by creating a new revision of the task definition and updating the image URI with the one just deployed.
For further assistance, please open an issue in this repository.
- If you encounter issues with the 9th step, refer to the related discussion on the AWS CDK GitHub repository for further troubleshooting: [CDK Github Issue](https://github.com/aws/aws-cdk/issues/30258). You can also consult our [Troubleshooting CDK Deploy documentation](TROUBLESHOOTING_CDK_DEPLOY.md) for more detailed guidance.
- If you continue to experience issues, please reach out to **ai-cic@amazon.com** for further assistance.

## Additional Resources

For more details on the problem approach, industry impact, and our innovative solution developed by ASU CIC, please visit our blog: [PDF Accessibility Blog](https://smartchallenges.asu.edu/challenges/pdf-accessibility-ohio-state-university)



## Contributing

Contributions to this project are welcome. Please fork the repository and submit a pull request with your changes

## Release Notes

See the latest [Release Notes](RELEASE_NOTES.md) for version updates and improvements.
