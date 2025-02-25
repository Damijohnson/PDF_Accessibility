

# Use an ARM-compatible Python base image
FROM python:3.9

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    jq \
    less \
    sudo \
    fuse-overlayfs \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI v2 for ARM
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Install Node.js and npm for ARM
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Install AWS CDK
RUN npm install -g aws-cdk
RUN apt-get update && apt-get install -y bash

# Set working directory
WORKDIR /app

# Copy project files
COPY . /app

# Install Docker inside the container
RUN curl -fsSL https://get.docker.com | sh

# Set entrypoint to a startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
