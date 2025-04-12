# Use a Python 3.11 image
FROM python:3.11-slim AS base

# Install system dependencies: Tesseract OCR and its libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      tesseract-ocr \
      libtesseract-dev \
      gcc \
      build-essential \
      && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Set the working directory in the container
WORKDIR /app

# Copy the poetry configuration files first to take advantage of Docker caching
COPY pyproject.toml poetry.lock* /app/

# Configure Poetry not to use a virtual environment and install dependencies
RUN poetry config virtualenvs.create false && poetry install --no-root --only main

# Copy the model service code into the container
COPY model.py /app/

# Expose the ports as needed
EXPOSE 8080 8081

# Set the command to run your model service
CMD ["python", "model.py"]
