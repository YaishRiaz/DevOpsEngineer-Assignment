# Containerization Strategy for OCR Inference System

## Overview

This document outlines the containerization strategy for the two-microservice OCR inference system. The project consists of:

- **KServe Model Service**: A Python service (`model.py`) that uses Tesseract OCR to process images.
- **FastAPI Gateway Service**: A FastAPI application (`api-gateway.py`) that accepts image uploads, encodes them in base64, and proxies the request to the model service.

This document covers the rationale behind the Docker base image selection, security considerations, build optimization techniques, Dockerfile details, automation scripts for building images, and instructions for pushing the images to a Docker Hub private repository.

## 1. Base Image Selection Rationale

- **Python:3.11-slim**:
  - **Minimal Footprint**: The slim variant minimizes image size while providing a compatible Python 3.11 environment.
  - **Security**: Fewer packages mean a lower attack surface.
  - **Compatibility**: Matches the project requirements (`>=3.11, <3.13`).

## 2. Security Considerations

- **Minimal Package Installations**: 
  - Utilize `--no-install-recommends` with apt-get to install only necessary packages.
- **Cleanup**:
  - Remove apt cache after installations using `rm -rf /var/lib/apt/lists/*`.
- **Dependency Management via Poetry**:
  - Lock dependency versions using `pyproject.toml` and `poetry.lock` to avoid unexpected package versions.
- **Future Improvements**:
  - Option to run containers as non-root users for added security.

## 3. Build Optimization Techniques

- **Layer Caching**:
  - Copy dependency files (`pyproject.toml` and `poetry.lock`) first to benefit from Docker cache. Changes to application code do not force re-installation of dependencies.
- **Use of Slim Base Images**:
  - Reduces overall image size and build time.
- **Potential Multi-Stage Builds**:
  - For further optimization, separating build and runtime environments (not yet implemented).

## 4. Dockerfile Details

### Dockerfile for the KServe Model Service (`Dockerfile-model`)

```dockerfile
# Use a lightweight Python 3.11 slim image
FROM python:3.11-slim AS base

# Install system dependencies for Tesseract OCR and build tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      tesseract-ocr \
      libtesseract-dev \
      gcc \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Set working directory
WORKDIR /app

# Copy dependency files and install Python dependencies
COPY pyproject.toml poetry.lock* /app/
RUN poetry config virtualenvs.create false && \
    poetry install --no-root --only main

# Copy the application code
COPY model.py /app/

# Expose port 8080
EXPOSE 8080 8081

# Start the model service
CMD ["python", "model.py"]
```

### Dockerfile for the FastAPI Gateway Service (`Dockerfile-gateway`)

```dockerfile
# Use a lightweight Python 3.11 slim image
FROM python:3.11-slim AS base

# Install system dependencies for building (if needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      build-essential && \
    rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Set the working directory
WORKDIR /app

# Copy dependency files and install Python dependencies
COPY pyproject.toml poetry.lock* /app/
RUN poetry config virtualenvs.create false && \
    poetry install --no-root --only main

# Copy the application code
COPY api-gateway.py /app/

# Expose port 8001
EXPOSE 8001

# Start the FastAPI gateway service
CMD ["python", "api-gateway.py"]
```

Note: The gateway service's code has been modified so that the model service URL is set to
```
KSERVE_URL = "http://ocr-model-service:8080/v2/models/ocr-model/infer"
```

## 5. Automation Script for Building Docker Images
Created a bash script called `build_images.sh`:
```bash
#!/bin/bash

# Replace "yourdockerusername" with your actual Docker Hub username
DOCKER_USERNAME="yourdockerusername"

echo "Building the model service image..."
docker build -f Dockerfile-model -t $DOCKER_USERNAME/ocr-model-service:latest .

echo "Building the API gateway image..."
docker build -f Dockerfile-gateway -t $DOCKER_USERNAME/ocr-api-gateway:latest .

echo "Build process complete."
```
made it executable and run it
```
chmod +x build_images.sh
./build_images.sh
```

## 6. Pushed the Images to the Docker Hub
Tagged and pushed the images:
```
docker login

docker tag yaishriaz/ocr-model-service:latest yourdockerusername/ocr-model-service:latest
docker push yourdockerusername/ocr-model-service:latest

docker tag yaishriaz/ocr-api-gateway:latest yourdockerusername/ocr-api-gateway:latest
docker push yourdockerusername/ocr-api-gateway:latest

```