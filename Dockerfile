# Minimal debug container for network and DNS troubleshooting
# Based on Alpine Linux for minimal size and security
FROM alpine:latest

# Install all required packages in a single layer for minimal image size
# Using apk update and upgrade to ensure latest patched packages
# Note: We upgrade packages to get latest security patches from Alpine repos
RUN apk update && \
    apk upgrade && \
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
    # Required for setcap to set capabilities on binaries
    libcap \
    && rm -rf /var/cache/apk/*

# Create a non-root user for security best practices
# Using fixed UID/GID 1000 for consistency
RUN addgroup -g 1000 debug && \
    adduser -D -u 1000 -G debug debug && \
    # Create home directory for the user
    mkdir -p /home/debug && \
    chown -R debug:debug /home/debug

# Set capabilities on binaries that need elevated privileges
# Note: These capabilities must also be granted at runtime (Docker/Kubernetes)
# tcpdump needs NET_RAW for packet capture
RUN setcap cap_net_raw+ep /usr/sbin/tcpdump || true
# ping (via busybox) needs NET_RAW for ICMP
RUN setcap cap_net_raw+ep /bin/busybox || true

# Switch to non-root user
USER debug:debug

# Set working directory to user's home
WORKDIR /home/debug

# Set default command to bash for interactive use
CMD ["/bin/bash"]
