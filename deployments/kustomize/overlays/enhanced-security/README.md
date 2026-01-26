# Enhanced Security Overlay

Adds **read-only root filesystem** hardening to the base configuration.

> [!IMPORTANT]
> This is a **Kubernetes-only** feature. Read-only filesystem is not available in plain Docker.

## What This Adds

| Feature | Base | Enhanced |
|---------|------|----------|
| Non-root user | ✅ | ✅ |
| NET_RAW capability | ✅ | ✅ |
| No privilege escalation | ✅ | ✅ |
| **Read-only filesystem** | ❌ | ✅ |
| **Volume mounts** | ❌ | ✅ |
| Docker-compatible | ✅ | ❌ |

## Quick Start

```bash
# Apply the enhanced security overlay
kubectl apply -k deployments/kustomize/overlays/enhanced-security

# Connect to the pod
kubectl exec -it debug-shell -- /bin/bash
```

## When to Use

> [!TIP]
> **Use this when:**
> - You need additional filesystem hardening
> - Compliance requirements mandate read-only root
> - Production environments with strict security policies

> [!WARNING]
> **Don't use this when:**
> - Using plain Docker (not supported)
> - You want the simplest possible deployment
> - You don't have specific filesystem hardening requirements

## Available Tools

All tools work with this configuration. Tools that create temporary files automatically use the mounted writable directories:

| Tool | Works | Notes |
|------|-------|-------|
| DNS tools (`dig`, `nslookup`, `drill`) | ✅ | No restrictions |
| HTTP clients (`curl`, `wget`) | ✅ | No restrictions |
| Network utilities (`netcat`, `netstat`, `ss`, `ip`) | ✅ | No restrictions |
| `ping`, `tcpdump`, `nmap` | ✅ | NET_RAW included |
| `strace` | ⚠️ | Requires SYS_PTRACE (see customization) |

## How It Works

The [overlay](./pod-patch.yaml) patches the base pod configuration. This allows tools to create temporary files while keeping the root filesystem read-only.

## Customization

### Adding SYS_PTRACE for strace

Create `strace-patch.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: debug-shell
spec:
  containers:
  - name: debug-shell
    securityContext:
      capabilities:
        add:
          - NET_RAW
          - SYS_PTRACE
```

Update `kustomization.yaml`:

```yaml
patches:
  - path: pod-patch.yaml
  - path: strace-patch.yaml
```

## Troubleshooting

<details>
<summary><strong>Tools can't write files</strong></summary>

- Verify volume mounts: `kubectl describe pod debug-shell`
- Ensure tools use `/tmp` or `/home/debug` for temporary files
</details>

<details>
<summary><strong>Pod won't start</strong></summary>

- Verify Kubernetes version supports read-only filesystem
- Check volume mount permissions
</details>

<details>
<summary><strong>Need simpler configuration?</strong></summary>

Use the [base configuration](../../base/) instead. It's secure and works for most use cases.
</details>

## See Also

- [Base Configuration](../../base/README.md)
- [Maximum Security Overlay](../maximum-security/README.md)
- [Deployment Plan](../../../../docs/deployment-plan.md)
