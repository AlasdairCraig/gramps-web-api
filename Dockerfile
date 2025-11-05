# Use full Python image to avoid missing build tools
FROM python:3.11

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV GRAMPS_API_CONFIG=/app/config/config.cfg
ENV PYTHONUNBUFFERED=1
ENV PORT=8080
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    graphviz \
    poppler-utils \
    ffmpeg \
    tesseract-ocr \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set locale
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
ENV LANGUAGE en_US.utf8
ENV LC_ALL en_US.utf8

# Install Python dependencies
RUN python3 -m pip install --no-cache-dir --upgrade pip setuptools wheel
RUN python3 -m pip install --no-cache-dir gunicorn gramps-webapi==3.4.1 psycopg2-binary==2.9.9

# Create app directories
RUN mkdir -p /app/config /app/media /app/cache /app/users /app/static

# Expose Render’s port
EXPOSE 8080

# Default command for Render
CMD gunicorn -w 4 -b 0.0.0.0:${PORT} "gramps_webapi.app:app" --timeout 120 --limit-request-line 8190
