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

# Install necessary system dependencies (minus heavy AI libraries)
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
    libatlas-base-dev \
    tesseract-ocr \
    libopenblas-dev \
    cmake \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Create directories for the app
RUN mkdir -p /app/src /app/config /app/static /app/db /app/media /app/indexdir /app/users \
    /app/thumbnail_cache /app/cache/reports /app/cache/export /app/cache/request_cache /app/cache/persistent_cache \
    /app/tmp /app/persist /root/gramps/gramps$GRAMPS_VERSION/plugins

# Set Gramps config environment variables
ENV GRAMPSWEB_USER_DB_URI=sqlite:////app/users/users.sqlite
ENV GRAMPSWEB_MEDIA_BASE_DIR=/app/media
ENV GRAMPSWEB_SEARCH_INDEX_DB_URI=sqlite:////app/indexdir/search_index.db
ENV GRAMPSWEB_STATIC_PATH=/app/static
ENV GRAMPSWEB_THUMBNAIL_CACHE_CONFIG__CACHE_DIR=/app/thumbnail_cache
ENV GRAMPSWEB_REQUEST_CACHE_CONFIG__CACHE_DIR=/app/cache/request_cache
ENV GRAMPSWEB_PERSISTENT_CACHE_CONFIG__CACHE_DIR=/app/cache/persistent_cache
ENV GRAMPSWEB_REPORT_DIR=/app/cache/reports
ENV GRAMPSWEB_EXPORT_DIR=/app/cache/export
ENV GRAMPSHOME=/root
ENV GRAMPS_DATABASE_PATH=/root/.gramps/grampsdb

# Install gunicorn
RUN python3 -m pip install --break-system-packages --no-cache-dir gunicorn

# Install only necessary Python dependencies (without heavy extras)
COPY requirements.txt .
RUN python3 -m pip install --break-system-packages --no-cache-dir -r requirements.txt

# Install only Gramps essentials
COPY . /app/src
RUN python3 -m pip install --break-system-packages --no-cache-dir /app/src

# Expose port for Gunicorn to run on
EXPOSE 5000

# Entry point and command for Gunicorn
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD gunicorn -w ${GUNICORN_NUM_WORKERS:-2} -b 0.0.0.0:${PORT:-5000} "gramps_webapi.app:app" --timeout ${GUNICORN_TIMEOUT:-120} --limit-request-line 8190
