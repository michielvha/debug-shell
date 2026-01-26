# Debug Shell

A minimal, community-maintained debug container for network and DNS troubleshooting in Kubernetes and Docker environments.

## Overview

Debug Shell is a lightweight Alpine-based container that provides essential network and DNS troubleshooting tools. It's designed as a modern, well-maintained alternative to `nicolaka/netshoot`, focusing on core functionality while maintaining a minimal footprint.

## Features

- 🔒 **Security-First Design**: Runs as non-root user, capability-based access, hardened by default
- 🐳 **Minimal Size**: Based on Alpine Linux (~20-30MB)
- 🏗️ **Multi-Architecture**: Supports `linux/amd64` and `linux/arm64`
- 🛠️ **Essential Tools**: Core DNS and network troubleshooting utilities
- 📦 **OCI Compliant**: Works with any container registry
- 📚 **Comprehensive Security**: See [Security Hardening Guide](docs/security-hardening.md) for details

## Included Tools

| Category | Tool | Description | Package |
|----------|------|-------------|---------|
| **DNS** | `dig` | DNS lookup utility | `bind-tools` |
| | `nslookup` | Interactive DNS query tool | `bind-tools` |
| | `drill` | DNS client and resolver | `ldns-tools` |
| **Connectivity** | `ping` | Test network connectivity | `iputils` |
| | `curl` | HTTP client for testing services | `curl` |
| | `wget` | HTTP client for downloading files | `wget` |
| | `nc`/`netcat` | Network utility for reading/writing connections | `netcat-openbsd` |
| **Inspection** | `tcpdump` | Packet analyzer for network troubleshooting | `tcpdump` |
| | `nmap` | Network mapper and port scanner | `nmap` |
| | `netstat` | Network connections and routing table | `net-tools` |
| | `ip` | Advanced network configuration | `iproute2` |
| | `ss` | Socket statistics | `iproute2` |
| **System** | `strace` | System call tracer for debugging | `strace` |
| | `bash` | Enhanced shell for better script compatibility | `bash` |

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

# Port scanning (requires NET_RAW capability)
nmap -p 80,443 example.com
nmap -sn 192.168.1.0/24  # Ping scan
nmap -sV example.com      # Version detection

# Capture packets (requires NET_RAW capability)
tcpdump -i any -n
```

### Process Debugging

```bash
# Trace system calls
strace -p <pid>
```

## Image Tags

| Tag | Description | Example |
|-----|-------------|---------|
| `latest` | Latest stable release | `ghcr.io/user/debug-shell:latest` |
| `{version}` | Semantic version | `ghcr.io/user/debug-shell:1.0.0` |
| `{sha}` | Git commit SHA | `ghcr.io/user/debug-shell:abc1234` |

## Comparison with netshoot

| Feature | Debug Shell | netshoot |
|---------|-------------|----------|
| Base Image | Alpine Linux | Alpine Linux |
| Size | ~20-30MB | ~100MB+ |
| Maintenance | Active | Limited |
| Tools | Core essentials | Extensive |
| Multi-arch | ✅ Yes | ✅ Yes |
| Security Updates | Regular | Infrequent |
| Runs as Root | ❌ No (non-root by default) | ✅ Yes |
| Security Hardening | ✅ Capability-based, hardened | ❌ Full root access |
| Security Documentation | ✅ Comprehensive guide | ❌ None |

## Security

**Security is a core design principle of debug-shell.** Unlike other debug containers that run as root, debug-shell is built with security best practices from the ground up.

### Key Security Features

| Feature | Description |
|---------|-------------|
| **Non-root execution** | Runs as `debug` user (UID 1000) by default |
| **Capability-based access** | Uses Linux capabilities instead of full root privileges |
| **Minimal attack surface** | Only essential tools, no unnecessary packages |
| **Regular security updates** | Pinned Alpine version automatically updated via Renovate |
| **Hardening roadmap** | See [Security Hardening Guide](docs/security-hardening.md) for additional measures |

### Security Considerations

This container follows security best practices:

- **Runs as non-root user** (`debug` user, UID 1000) by default
- **Minimal capabilities**: Only specific Linux capabilities are granted to binaries that need them
- **Capability-based access**: Tools requiring elevated privileges use Linux capabilities instead of full root access

### Required Capabilities

Some tools require specific Linux capabilities to function. These must be granted at runtime:

| Tool | Required Capability | Purpose |
|------|-------------------|---------|
| `tcpdump` | `NET_RAW` | Packet capture |
| `ping` | `NET_RAW` | ICMP packets |
| `nmap` | `NET_RAW` | Network scanning and port detection |

### Docker Usage

For tools requiring capabilities, add them when running:

```bash
# Basic usage (most tools work without capabilities)
docker run -it --rm ghcr.io/<username>/debug-shell:latest

# For tcpdump or ping, add NET_RAW capability
docker run -it --rm --cap-add=NET_RAW ghcr.io/<username>/debug-shell:latest

# For strace, add SYS_PTRACE capability
docker run -it --rm --cap-add=SYS_PTRACE ghcr.io/<username>/debug-shell:latest
```

### Kubernetes Usage

Add capabilities via security context:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug
spec:
  containers:
  - name: debug-shell
    image: ghcr.io/<username>/debug-shell:latest
    securityContext:
      runAsNonRoot: true
      runAsUser: 1000
      runAsGroup: 1000
      allowPrivilegeEscalation: false
      capabilities:
        add:
          - NET_RAW      # Required for tcpdump and ping
        drop:
          - ALL          # Drop all other capabilities
    command: ["/bin/bash"]
    args: ["-c", "while true; do sleep 3600; done"]
```

**For strace debugging:**
```yaml
securityContext:
  capabilities:
    add:
      - NET_RAW
      - SYS_PTRACE     # Required for strace
    drop:
      - ALL
```

### Security Best Practices

| Practice | Implementation |
|----------|----------------|
| **Run as non-root** | Container defaults to UID 1000 |
| **Least privilege** | Only add capabilities you actually need |
| **Drop capabilities** | In Kubernetes, explicitly drop ALL and add only what's needed |
| **Read-only filesystem** | Consider using `readOnlyRootFilesystem: true` in production (see [Security Hardening Guide](docs/security-hardening.md)) |
| **No privilege escalation** | Set `allowPrivilegeEscalation: false` |

### Advanced Security Hardening

Additional hardening options available:

| Option | Status |
|--------|--------|
| Read-only root filesystem | Planned |
| Seccomp profiles | Planned |
| Resource limits | Planned |
| Image signing | Planned |

See the comprehensive [Security Hardening Guide](docs/security-hardening.md) for detailed implementation plans and security profiles.

### Vulnerability Management

| Aspect | Details |
|--------|---------|
| **Automated Scanning** | Every build is scanned with Trivy and fails on CRITICAL, HIGH, or MEDIUM vulnerabilities |
| **Known Issues** | Tracked in [Security Vulnerabilities](docs/security-vulnerabilities.md) |
| **Update Strategy** | Dockerfile uses `apk upgrade` to automatically include latest security patches from Alpine repos |
| **Transparency** | All known vulnerabilities are documented with mitigation status |

## Contributing

This is a community-maintained project. Contributions are welcome!

## License

[Add your license here]

## Support

For issues, questions, or contributions, please open an issue in the repository.
