# Simplified Dockerfile for Radicale + InfCloud (Single Process)
FROM python:3.11-slim as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-dev \
        curl \
        && rm -rf /var/lib/apt/lists/*

# Set versions for reproducible builds
ENV RADICALE_VERSION=3.1.9
ENV INFCLOUD_VERSION=0.13.1

# Install Python packages with compatible versions
RUN pip install --no-cache-dir \
    radicale==$RADICALE_VERSION \
    'bcrypt>=3.2.0,<4.0.0' \
    'passlib>=1.7.4,<1.8.0'

# Download and extract InfCloud from official source with robust error handling
RUN apt-get update && apt-get install -y unzip wget && rm -rf /var/lib/apt/lists/* && \
    mkdir -p /tmp/infcloud && \
    echo "Attempting to download InfCloud from multiple sources..." && \
    (wget --timeout=30 --tries=3 -O /tmp/infcloud.zip "https://www.inf-it.com/InfCloud_${INFCLOUD_VERSION}.zip" || \
     wget --timeout=30 --tries=3 -O /tmp/infcloud.zip "https://inf-it.com/InfCloud_${INFCLOUD_VERSION}.zip" || \
     curl -L --max-time 30 --retry 3 "https://www.inf-it.com/InfCloud_${INFCLOUD_VERSION}.zip" -o /tmp/infcloud.zip || \
     curl -L --max-time 30 --retry 3 "https://inf-it.com/InfCloud_${INFCLOUD_VERSION}.zip" -o /tmp/infcloud.zip) && \
    echo "Download completed. File info:" && \
    ls -la /tmp/infcloud.zip && \
    file /tmp/infcloud.zip && \
    echo "Extracting InfCloud..." && \
    unzip -q /tmp/infcloud.zip -d /tmp/extract/ && \
    echo "Extraction completed. Contents:" && \
    find /tmp/extract -type f -name "*.html" -o -name "*.js" | head -10 && \
    echo "Moving files to final location..." && \
    (if [ -d "/tmp/extract/InfCloud_${INFCLOUD_VERSION}" ]; then \
        cp -r /tmp/extract/InfCloud_${INFCLOUD_VERSION}/* /tmp/infcloud/; \
    elif [ -d "/tmp/extract/infcloud" ]; then \
        cp -r /tmp/extract/infcloud/* /tmp/infcloud/; \
    else \
        find /tmp/extract -mindepth 1 -maxdepth 1 -type d -exec cp -r {}/* /tmp/infcloud/ \; ; \
    fi) && \
    echo "Final InfCloud files:" && \
    ls -la /tmp/infcloud/ && \
    rm -rf /tmp/infcloud.zip /tmp/extract

# Production stage
FROM python:3.11-slim

# Install runtime dependencies (only curl for health checks)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        && rm -rf /var/lib/apt/lists/* \
        && apt-get clean

# Copy Python packages from builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy InfCloud to Radicale's web directory
COPY --from=builder /tmp/infcloud /var/lib/radicale/web

# Create necessary directories
RUN mkdir -p /etc/radicale \
             /var/lib/radicale/collections \
             /var/log/radicale

# Copy configuration files
COPY config/radicale.conf /etc/radicale/config
COPY config/logging.conf /etc/radicale/logging.conf
COPY config/infcloud-config.js /var/lib/radicale/web/config.js

# Copy user creation script
COPY create-user.py /usr/local/bin/create-user.py
RUN chmod +x /usr/local/bin/create-user.py

# Create radicale user and set permissions
RUN useradd --system --home-dir /var/lib/radicale --shell /bin/false radicale && \
    chown -R radicale:radicale /var/lib/radicale /var/log/radicale /etc/radicale

# Create default users file (can be overridden with volume mount)
RUN echo "# Radicale users file" > /etc/radicale/users && \
    echo "# Format: username:password_hash" >> /etc/radicale/users && \
    echo "# Generate hash with: python3 -c \"import bcrypt; print(bcrypt.hashpw(b'password', bcrypt.gensalt()).decode())\"" >> /etc/radicale/users && \
    chown radicale:radicale /etc/radicale/users

# Expose port (Radicale will serve both CalDAV and web interface)
EXPOSE 5232

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:5232/.web/ || exit 1

# Set working directory
WORKDIR /var/lib/radicale

# Switch to radicale user
USER radicale

# Start Radicale (single process)
CMD ["radicale", "--config", "/etc/radicale/config"]
