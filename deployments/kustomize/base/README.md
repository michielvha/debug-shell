# Debug Shell - Kustomize Base

Base kustomize configuration with **moderate security** defaults that work out-of-the-box.

> [!TIP]
> This is the recommended starting point for most users. It provides strong security while maintaining simplicity and Docker-like behavior.

## Security Profile

| Feature | Status | Details |
|---------|--------|---------|
| **User** | Non-root | Runs as UID 1000 |
| **Filesystem** | Writable | Simple, Docker-compatible |
| **Capabilities** | NET_RAW | Enables ping, tcpdump, nmap |
| **Privilege Escalation** | Disabled | `allowPrivilegeEscalation: false` |
| **Seccomp** | Enabled | RuntimeDefault profile |
| **Resources** | Limited | 2 CPU / 512Mi memory |

## Quick Start

```bash
# Apply the base configuration
kubectl apply -k deployments/kustomize/base

# Connect to the pod
kubectl exec -it debug-shell -- /bin/bash
```

That's it! The pod is ready to use.

## Customization

### Image Tag

```bash
cd deployments/kustomize/base
kustomize edit set image ghcr.io/michielvha/debug-shell:v1.0.0
```

Or edit `kustomization.yaml` directly:

```yaml
images:
  - name: ghcr.io/michielvha/debug-shell
    newName: ghcr.io/michielvha/debug-shell
    newTag: v1.0.0
```

### Namespace

```bash
kustomize edit set namespace your-namespace
```

## Available Tools

| Category | Tools | Capability Required |
|----------|-------|---------------------|
| **DNS** | `dig`, `nslookup`, `drill` | None |
| **HTTP** | `curl`, `wget` | None |
| **Network** | `netcat`, `netstat`, `ss`, `ip` | None |
| **Connectivity** | `ping`, `tcpdump`, `nmap` | NET_RAW ✅ |
| **System** | `strace` | SYS_PTRACE (optional) |

> [!NOTE]
> Most tools work without additional configuration. Only `strace` requires adding `SYS_PTRACE` capability if needed.

## Why Writable Filesystem?

The base configuration prioritizes simplicity and compatibility:

| Aspect | Benefit |
|--------|---------|
| **Simplicity** | Works like `docker run -it --rm image` |
| **Compatibility** | All tools work without special config |
| **Security** | Still follows best practices (non-root, capabilities) |
| **Docker-friendly** | Easy transition from Docker to Kubernetes |

> [!TIP]
> Need filesystem hardening? Check out the [enhanced-security overlay](../overlays/enhanced-security/) for read-only filesystem support.

## Resource Limits

| Resource | Limit | Request |
|----------|-------|---------|
| **CPU** | 2 cores | 100m |
| **Memory** | 512Mi | 128Mi |

Adjust in `pod.yaml` if needed for your environment.

## Security Overlays

For additional security options:

| Overlay | Use Case | Key Feature |
|---------|----------|-------------|
| **[enhanced-security](../overlays/enhanced-security/)** | Production hardening | Read-only filesystem |
| **[maximum-security](../overlays/maximum-security/)** | Highly restricted | No capabilities |

## Troubleshooting

<details>
<summary><strong>Pod won't start</strong></summary>

- Check image pull permissions
- Verify namespace exists
- Check resource quotas
</details>

<details>
<summary><strong>Tools not working</strong></summary>

Most tools work without additional configuration. For `strace`, you may need to add `SYS_PTRACE` capability (see [enhanced-security overlay](../overlays/enhanced-security/)).
</details>

<details>
<summary><strong>Need more security?</strong></summary>

- Use the [enhanced-security overlay](../overlays/enhanced-security/) for read-only filesystem
- Use the [maximum-security overlay](../overlays/maximum-security/) for maximum restrictions
</details>

## See Also

- [Deployment Plan](../../../docs/deployment-plan.md)
- [Security Hardening Guide](../../../docs/security-hardening.md)
- [Main README](../../../README.md)
