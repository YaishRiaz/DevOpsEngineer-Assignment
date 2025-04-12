#!/bin/bash

# Build the Docker image for the KServe model service
echo "Building the model service image..."
docker build -f docker/model/Dockerfile -t yaishriaz/ocr-model-service:latest .

# Build the Docker image for the FastAPI gateway
echo "Building the API gateway image..."
docker build -f docker/gateway/Dockerfile -t yaishriaz/ocr-api-gateway:latest .

echo "Build process complete."
