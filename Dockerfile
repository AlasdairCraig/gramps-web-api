FROM python:3.11-slim

# Set working directory
WORKDIR /app

# System deps needed by Gramps + psycopg2
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libgirepository1.0-dev \
    gir1.2-gtk-3.0 \
    libicu-dev \
    libcairo2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy only requirements first for caching
COPY requirements.txt .

# Install core dependencies without heavy extras
RUN pip install --no-cache-dir gramps-webapi==3.4.1 gunicorn psycopg2-binary

# Copy source
COPY . .

# Environment vars
ENV PORT=8080
ENV GUNICORN_NUM_WORKERS=2
ENV GUNICORN_TIMEOUT=120
ENV PYTHONUNBUFFERED=1

# Run Gunicorn
CMD gunicorn -w ${GUNICORN_NUM_WORKERS} -b 0.0.0.0:${PORT} "gramps_webapi.app:app" --timeout ${GUNICORN_TIMEOUT} --limit-request-line 8190


