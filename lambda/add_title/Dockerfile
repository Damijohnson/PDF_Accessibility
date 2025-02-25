FROM python:3.10-slim-buster


# Set environment variable for Lambda Task Root (optional but recommended)
ENV LAMBDA_TASK_ROOT=/asset

# Copy function code to the /asset directory
COPY myapp.py /asset/

# Copy requirements.txt to /tmp directory
COPY requirements.txt /tmp/

# Upgrade pip to the latest version

RUN pip install --upgrade pip
# Install dependencies into /asset
RUN pip install --no-cache-dir -r /tmp/requirements.txt -t /asset/

# (Optional) Clean up /tmp to reduce image size
RUN rm -rf /tmp/*

# Set the working directory to /asset
WORKDIR /asset

# Specify the Lambda handler
CMD ["myapp.lambda_handler"]