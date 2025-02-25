FROM public.ecr.aws/lambda/python:3.12

# Copy function code to the /var/task directory
COPY myapp.py /var/task/

# Copy requirements.txt to /tmp directory
COPY requirements.txt /tmp/

# Upgrade pip to the latest version
RUN pip3 install --upgrade pip

# Install dependencies into /var/task
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt -t /var/task/

# (Optional) Clean up /tmp to reduce image size
RUN rm -rf /tmp/*

# Set the working directory to /var/task
WORKDIR /var/task

# Specify the Lambda handler
CMD ["myapp.lambda_handler"]