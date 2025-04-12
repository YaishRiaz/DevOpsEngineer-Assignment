# Use a Python 3.11 image
FROM python:3.11-slim AS base

# Install system dependencies (adjust as needed)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      gcc \
      build-essential \
      && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry

# Set the working directory
WORKDIR /app

# Copy the poetry configuration files
COPY pyproject.toml poetry.lock* /app/

# Install the dependencies using Poetry without creating a separate virtual environment
RUN poetry config virtualenvs.create false && poetry install --no-root --only main

# Copy the FastAPI gateway code into the container
COPY api-gateway.py /app/

# Expose port 8001 (which the gateway uses)
EXPOSE 8001

# Set the command to run your FastAPI gateway service
CMD ["python", "api-gateway.py"]
