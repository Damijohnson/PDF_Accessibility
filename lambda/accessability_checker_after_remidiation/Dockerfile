# Use the official AWS Lambda Python 3.10 base image compatible with ARM64 architecture
FROM public.ecr.aws/lambda/python:3.10

# Copy function code and requirements
COPY main.py /var/task/
COPY requirements.txt /tmp/

# Install dependencies into the Lambda task root
RUN pip3 install -r /tmp/requirements.txt --target /var/task/
