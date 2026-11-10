# Minimal debug container for network and DNS troubleshooting
# Based on Alpine Linux for minimal size and security
FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

# Install all required packages in a single layer for minimal image size
# Using apk update and upgrade to ensure latest patched packages
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
    # Shell
    bash \
    # DNS tools
    bind-tools \
    ldns-tools \
    drill \
    # Network connectivity
    iputils \
    curl \
    wget \
    netcat-openbsd \
    # Network inspection
    tcpdump \
    nmap \
    net-tools \
    iproute2 \
    # System utilities
    strace \
    # Required for setcap to set capabilities on binaries
    libcap \
    && rm -rf /var/cache/apk/*

# Create a non-root user for security best practices
RUN addgroup -g 1000 debug && \
    adduser -D -u 1000 -G debug debug && \
    # Create home directory for the user
    mkdir -p /home/debug && \
    chown -R debug:debug /home/debug

# Keep BusyBox applets usable when NET_RAW is dropped.
RUN chmod u-s /bin/ping && \
    setcap cap_net_raw+ep /bin/ping && \
    setcap cap_net_raw+ep /usr/bin/tcpdump && \
    setcap cap_net_raw+ep /usr/bin/nmap

# Switch to non-root user
USER debug:debug

# Set working directory to user's home
WORKDIR /home/debug

# Set default command to bash for interactive use
CMD ["/bin/bash"]
