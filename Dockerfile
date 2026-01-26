# Minimal debug container for network and DNS troubleshooting
# Based on Alpine Linux for minimal size and security
FROM alpine:latest

# Install all required packages in a single layer for minimal image size
# Using apk update to ensure latest packages
RUN apk update && \
    apk add --no-cache \
    # Shell
    bash \
    # DNS tools
    bind-tools \
    ldns-tools \
    # Network connectivity
    iputils \
    curl \
    wget \
    netcat-openbsd \
    # Network inspection
    tcpdump \
    net-tools \
    iproute2 \
    # System utilities
    strace \
    && rm -rf /var/cache/apk/*

# Set default command to bash for interactive use
CMD ["/bin/bash"]
