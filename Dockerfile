# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies for PIL/Pillow
RUN apt-get update && apt-get install -y \
    libjpeg-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file (if exists) or install dependencies directly
# Install Python dependencies
RUN pip install --no-cache-dir \
    Pillow \
    numpy

# Copy application code
COPY . .

# Make entrypoint script executable
RUN chmod +x /app/entrypoint.sh

# Create directories for input/output if they don't exist
RUN mkdir -p /app/input /app/output

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Set entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command shows help (will be passed to entrypoint)
CMD []
