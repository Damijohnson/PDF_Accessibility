FROM public.ecr.aws/lambda/python:3.10.2024.06.14.14

# Set the working directory to /var/task
WORKDIR /var/task

# Copy main.py to the working directory
COPY main.py .

# Copy requirements.txt to a temporary location
COPY requirements.txt /tmp/

# Install dependencies to the working directory
RUN pip3 install --no-cache-dir -r /tmp/requirements.txt -t .

# Set the CMD to your handler
CMD ["main.lambda_handler"]