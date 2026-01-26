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
docker run -it --rm ghcr.io/michielvha/debug-shell:latest

# Run with network access to another container
docker run -it --rm --network container:<container-name> ghcr.io/michielvha/debug-shell:latest

# Run with host network (Linux only)
docker run -it --rm --network host ghcr.io/michielvha/debug-shell:latest

# For tools requiring capabilities (ping, tcpdump, nmap)
docker run -it --rm --cap-add=NET_RAW ghcr.io/michielvha/debug-shell:latest

# For strace debugging
docker run -it --rm --cap-add=SYS_PTRACE ghcr.io/michielvha/debug-shell:latest
```

### Kubernetes

> [!TIP]
> For production deployments, use our [Kustomize configurations](deployments/kustomize/) or [Helm chart](deployments/helm/debug-shell/) with configurable security profiles.

#### Quick Start with Helm

```bash
# Install with moderate security (default)
helm install debug-shell oci://ghcr.io/michielvha/charts/debug-shell

# Install with enhanced security (read-only filesystem)
helm install debug-shell oci://ghcr.io/michielvha/charts/debug-shell \
  -f https://raw.githubusercontent.com/michielvha/debug-shell/main/deployments/helm/debug-shell/values-enhanced.yaml
```

#### Quick Start with Kustomize

```bash
# Apply base configuration (moderate security)
kubectl apply -k https://github.com/michielvha/debug-shell/deployments/kustomize/base

# Apply enhanced security overlay
kubectl apply -k https://github.com/michielvha/debug-shell/deployments/kustomize/overlays/enhanced-security
```

#### As an Ephemeral Container (Kubernetes 1.23+)

```bash
kubectl debug <pod-name> -it --image=ghcr.io/michielvha/debug-shell:latest --target=<container-name>
```

#### Deployment Options

| Option | Use Case | Documentation |
|--------|----------|---------------|
| **[Helm Chart](deployments/helm/debug-shell/)** | Production deployments, CI/CD | [Helm README](deployments/helm/debug-shell/README.md) |
| **[Kustomize Base](deployments/kustomize/base/)** | Simple deployments, GitOps | [Kustomize README](deployments/kustomize/base/README.md) |
| **[Kustomize Overlays](deployments/kustomize/overlays/)** | Security profiles, customization | See overlays directory |

All deployment options include:
- ✅ Multiple security profiles (Moderate, Enhanced, Maximum)
- ✅ Proper security contexts (non-root, capabilities, seccomp)
- ✅ Resource limits
- ✅ Ready-to-use configurations

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
| `latest` | Latest stable release | `ghcr.io/michielvha/debug-shell:latest` |
| `{version}` | Semantic version | `ghcr.io/michielvha/debug-shell:1.0.0` |
| `{sha}` | Git commit SHA | `ghcr.io/michielvha/debug-shell:abc1234` |

## Helm Chart

The Helm chart is published to OCI registry and can be installed directly:

```bash
# Install latest version
helm install debug-shell oci://ghcr.io/michielvha/charts/debug-shell

# Install specific version
helm install debug-shell oci://ghcr.io/michielvha/charts/debug-shell --version 1.0.0
```

See the [Helm chart documentation](deployments/helm/debug-shell/README.md) for configuration options and security profiles.

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

Most tools work without additional capabilities. For tools requiring elevated privileges:

| Tool | Capability | Docker Command |
|-----|-----------|----------------|
| `ping`, `tcpdump`, `nmap` | `NET_RAW` | `docker run -it --rm --cap-add=NET_RAW ghcr.io/michielvha/debug-shell:latest` |
| `strace` | `SYS_PTRACE` | `docker run -it --rm --cap-add=SYS_PTRACE ghcr.io/michielvha/debug-shell:latest` |






### Security Best Practices

| Practice | Implementation |
|----------|----------------|
| **Run as non-root** | Container defaults to UID 1000 |
| **Least privilege** | Only add capabilities you actually need |
| **Drop capabilities** | All deployments drop ALL and add only required |
| **Read-only filesystem** | Available in Enhanced and Maximum security profiles |
| **No privilege escalation** | Enabled in all deployment configurations |
| **Seccomp profile** | RuntimeDefault enabled in all profiles |
| **Resource limits** | Configured in all deployment options |

### Security Profiles

Three security profiles are available in all deployment options:

| Profile | Filesystem | Capabilities | Use Case |
|---------|-----------|--------------|----------|
| **Moderate** (default) | Writable | NET_RAW | Most users, simple deployments |
| **Enhanced** | Read-only | NET_RAW | Security-conscious production |
| **Maximum** | Read-only | None | Highly restricted environments |

> [!NOTE]
> See the [Security Hardening Guide](docs/security-hardening.md) for detailed information about each profile and tool compatibility.

### Vulnerability Management

| Aspect | Details |
|--------|---------|
| **Automated Scanning** | Every build is scanned with Trivy and fails on CRITICAL, HIGH, or MEDIUM vulnerabilities |
| **Known Issues** | Tracked in [Security Vulnerabilities](docs/security-vulnerabilities.md) |
| **Update Strategy** | Dockerfile uses `apk upgrade` to automatically include latest security patches from Alpine repos |
| **Transparency** | All known vulnerabilities are documented with mitigation status |

## Documentation

- **[Deployment Guide](deployments/)** - Kustomize and Helm deployment options
- **[Security Hardening Guide](docs/security-hardening.md)** - Security features and profiles
- **[Security Vulnerabilities](docs/security-vulnerabilities.md)** - Known vulnerabilities and mitigation
- **[Deployment Plan](docs/deployment-plan.md)** - Implementation details and roadmap

## Contributing

This is a community-maintained project. Contributions are welcome!

## License

[Add your license here]

## Support

For issues, questions, or contributions, please open an issue in the repository.
