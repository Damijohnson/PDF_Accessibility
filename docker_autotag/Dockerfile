# Use an official Python runtime as a parent image
FROM python:3.10-slim-buster
USER root

# Set environment variables
ENV AWS_REGION="us-east-1"

# Set the working directory
WORKDIR /app

# Copy only requirements first (better for caching)
COPY requirements.txt requirements_for_ocr.txt /app/

# Install system dependencies and Python packages in one go
RUN apt-get update && \
    apt-get install -y gcc libgl1 libglib2.0-0 && \
    python -m pip install --upgrade pip && \
    pip install -r requirements.txt && \
    # Install CPU-only torch version
    pip install virtualenv && \
    # Create virtualenv for OCR specific code
    python -m virtualenv /app/venv && \
    . /app/venv/bin/activate && \
    # Install OCR requirements inside venv
    pip install torch==2.0.1+cpu torchvision==0.15.2+cpu --index-url https://download.pytorch.org/whl/cpu && \
    pip install  -r requirements_for_ocr.txt && \
    deactivate && \
    apt-get remove -y gcc && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

# Copy the rest of the application
COPY . /app

# Set the command to run your script
CMD ["python", "./autotag.py"]
