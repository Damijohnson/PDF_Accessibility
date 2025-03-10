# Use an official Python runtime as a parent image
FROM --platform=linux/amd64 python:3.10-slim-buster
USER root
# Set environment variables
ENV AWS_REGION="us-east-1"

# Set the working directory in the container to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app
# Debugging Step: Check available disk space
RUN df -h

# Debugging Step: Check available permissions on /output directory
RUN mkdir -p /output 


# Upgrade pip and install Python dependencies
RUN apt-get update && apt-get install -y gcc \
    && python -m pip install --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get remove -y gcc \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Verify that the application files are present
RUN ls -la /app

# Set the command to run the Python script when the container launches
CMD ["python", "./autotag.py"]
