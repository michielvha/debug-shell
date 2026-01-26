# Debug Shell

A minimal, community-maintained debug container for network and DNS troubleshooting in Kubernetes and Docker environments.

## Overview

Debug Shell is a lightweight Alpine-based container that provides essential network and DNS troubleshooting tools. It's designed as a modern, well-maintained alternative to `nicolaka/netshoot`, focusing on core functionality while maintaining a minimal footprint.

## Features

- 🐳 **Minimal Size**: Based on Alpine Linux (~20-30MB)
- 🔒 **Security-Focused**: Regular updates and minimal attack surface
- 🏗️ **Multi-Architecture**: Supports `linux/amd64` and `linux/arm64`
- 🛠️ **Essential Tools**: Core DNS and network troubleshooting utilities
- 📦 **OCI Compliant**: Works with any container registry

## Included Tools

### DNS Tools
- **dig** - DNS lookup utility (from `bind-tools`)
- **nslookup** - Interactive DNS query tool (from `bind-tools`)
- **drill** - DNS client and resolver (from `ldns-tools`)

### Network Connectivity
- **ping** - Test network connectivity (from `iputils`)
- **curl** - HTTP client for testing services
- **wget** - HTTP client for downloading files
- **nc/netcat** - Network utility for reading/writing network connections

### Network Inspection
- **tcpdump** - Packet analyzer for network troubleshooting
- **netstat** - Network connections and routing table (from `net-tools`)
- **ip** - Advanced network configuration (from `iproute2`)
- **ss** - Socket statistics (from `iproute2`)

### System Utilities
- **strace** - System call tracer for debugging
- **bash** - Enhanced shell for better script compatibility

## Usage

### Docker

```bash
# Run interactively
docker run -it --rm ghcr.io/<username>/debug-shell:latest

# Run with network access to another container
docker run -it --rm --network container:<container-name> ghcr.io/<username>/debug-shell:latest

# Run with host network (Linux only)
docker run -it --rm --network host ghcr.io/<username>/debug-shell:latest
```

### Kubernetes

#### As a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug
  namespace: default
spec:
  containers:
  - name: debug-shell
    image: ghcr.io/<username>/debug-shell:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do sleep 3600; done"]
```

#### As an Ephemeral Container (Kubernetes 1.23+)

```bash
kubectl debug <pod-name> -it --image=ghcr.io/<username>/debug-shell:latest --target=<container-name>
```

#### As a Sidecar

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: app-with-debug
spec:
  containers:
  - name: app
    image: your-app:latest
  - name: debug-shell
    image: ghcr.io/<username>/debug-shell:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do sleep 3600; done"]
```

## Common Use Cases

### DNS Troubleshooting

```bash
# Query DNS
dig example.com
nslookup example.com
drill example.com

# Query specific DNS server
dig @8.8.8.8 example.com
```

### Network Connectivity

```bash
# Test connectivity
ping google.com
curl -v https://example.com
wget https://example.com

# Test specific port
nc -zv example.com 443
```

### Network Inspection

```bash
# View network interfaces
ip addr show
ip route show

# View connections
netstat -tulpn
ss -tulpn

# Capture packets (requires capabilities)
tcpdump -i any -n
```

### Process Debugging

```bash
# Trace system calls
strace -p <pid>
```

## Image Tags

- `latest` - Latest stable release
- `{version}` - Semantic version (e.g., `1.0.0`)
- `{sha}` - Git commit SHA

## Comparison with netshoot

| Feature | Debug Shell | netshoot |
|---------|-------------|----------|
| Base Image | Alpine Linux | Alpine Linux |
| Size | ~20-30MB | ~100MB+ |
| Maintenance | Active | Limited |
| Tools | Core essentials | Extensive |
| Multi-arch | ✅ Yes | ✅ Yes |
| Security Updates | Regular | Infrequent |

## Security Considerations

- The container runs as root by default (some tools like `tcpdump` require elevated privileges)
- For production use, consider running with a non-root user where possible
- In Kubernetes, you may need to add security contexts or capabilities for certain tools:
  ```yaml
  securityContext:
    capabilities:
      add:
        - NET_RAW  # Required for tcpdump
  ```

## Contributing

This is a community-maintained project. Contributions are welcome!

## License

[Add your license here]

## Support

For issues, questions, or contributions, please open an issue in the repository.
