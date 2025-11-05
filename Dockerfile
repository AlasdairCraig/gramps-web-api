# Start with a lighter base image
FROM python:3.11-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV GRAMPS_VERSION=60
ENV PYTHONPATH="${PYTHONPATH}:/usr/lib/python3/dist-packages"
ENV GRAMPS_API_CONFIG=/app/config/config.cfg
ENV OMP_NUM_THREADS=1
ENV LANGUAGE en_US.utf8
ENV LANG en_US.utf8
ENV LC_ALL en_US.utf8

# Install necessary system dependencies (removed libatlas-base-dev)
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    libgirepository1.0-dev \
    gir1.2-gtk-3.0 \
    libicu-dev \
    graphviz \
    locales \
    gettext \
    wget \
    python3-pip \
    python3-pil \
    poppler-utils \
    ffmpeg \
    libavcodec-extra \
    unzip \
    libgl1-mesa-dev \
    libgtk2.0-dev \
    liblapack-dev \
    tesseract-ocr \
    libopenblas-dev \
    cmake \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Create directories for the app
RUN mkdir -p /app/src /app/config /app/static /app/db /app/media /app/indexdir /app/users \
    /app/thumbnail_cache /app/cache/reports /app/cache/export /app/cache/request_cache /app/cache/persistent_cache \
    /app/tmp /app/persist /root/gramps/gramps$GRAMPS_VERSION_
