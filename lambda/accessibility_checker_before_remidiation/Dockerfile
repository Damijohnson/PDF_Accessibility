# Use the official AWS Lambda Python 3.10 base image
FROM public.ecr.aws/lambda/python:3.10

# Copy function code and requirements
COPY main.py /var/task/
COPY requirements.txt /var/task/

# Install dependencies into the Lambda task root
RUN pip3 install -r /var/task/requirements.txt --target /var/task/
CMD ["main.lambda_handler"]