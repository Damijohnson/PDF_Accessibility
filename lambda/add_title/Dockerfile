# Use the official AWS Lambda Python 3.12 base image compatible with ARM64 architecture
FROM public.ecr.aws/lambda/python:3.12


# Copy function code and requirements
COPY myapp.py /var/task/
COPY requirements.txt /tmp/

# Upgrade pip to the latest version
RUN pip3 install --upgrade pip

# Install dependencies into the Lambda task root
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt -t /var/task/

# Clean up temporary files to reduce image size
RUN rm -rf /tmp/*

# Set the working directory
WORKDIR /var/task

# Specify the Lambda handler
CMD ["myapp.lambda_handler"]