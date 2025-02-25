# Use an official Node.js runtime as the base image, specifying the ARM architecture
FROM node:20

# Set the working directory in the container
WORKDIR /app

# Install required system dependencies for building native modules
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Set environment variables
ENV AWS_REGION="us-east-1"

# Copy the rest of the application source code
COPY . .

# Define the command to run the app
CMD ["node", "alt-text.js"]
