# Debug Shell Helm Chart

Helm chart for deploying debug-shell with configurable security profiles.

## Quick Start

```bash
# Moderate security (default - writable filesystem)
helm install debug-shell ./deployments/helm/debug-shell

# Enhanced security (read-only filesystem)
helm install debug-shell ./deployments/helm/debug-shell \
  -f ./deployments/helm/debug-shell/values-enhanced.yaml

# Maximum security (no capabilities)
helm install debug-shell ./deployments/helm/debug-shell \
  -f ./deployments/helm/debug-shell/values-maximum.yaml
```

## Security Profiles

| Profile | Filesystem | Capabilities | Use Case |
|---------|-----------|--------------|----------|
| **Moderate** (default) | Writable | NET_RAW | Most use cases, simple deployments |
| **Enhanced** | Read-only | NET_RAW | Security-conscious production |
| **Maximum** | Read-only | None | Highly restricted environments |

> [!WARNING]
> Maximum security profile disables several tools. See [values-maximum.yaml](values-maximum.yaml) for details.

### Moderate (Default)

> [!TIP]
> **Recommended for most users**

- Writable filesystem (simple, Docker-compatible)
- NET_RAW capability (enables ping, tcpdump, nmap)
- Non-root user
- No privilege escalation

### Enhanced

- Read-only filesystem (Kubernetes-only)
- NET_RAW capability
- Volume mounts for writable directories
- Non-root user
- No privilege escalation

> [!NOTE]
> Use when you need additional filesystem hardening for security-conscious production deployments or compliance requirements.

### Maximum

- Read-only filesystem
- **No capabilities** (disables ping, tcpdump, nmap, strace)
- Stricter resource limits
- Volume mounts for writable directories

> [!WARNING]
> This profile disables several tools. Only use in highly restricted environments where these tools aren't needed.

## Configuration

All configuration options are available in the [values.yaml](values.yaml) file. Key settings:

| Setting | Options | Default |
|---------|---------|---------|
| `image.repository` | Container registry path | `ghcr.io/michielvha/debug-shell` |
| `image.tag` | Image tag | `latest` |
| `securityProfile` | `moderate`, `enhanced`, `maximum` | `moderate` |
| `deploymentMode` | `pod`, `deployment`, `daemonset` | `pod` |
| `capabilities.add` | `NET_RAW`, `SYS_PTRACE` | `[NET_RAW]` |
| `resources.limits.cpu` | CPU cores | `2` |
| `resources.limits.memory` | Memory | `512Mi` |

> [!TIP]
> See [values.yaml](values.yaml) for all available options, or use the profile-specific values files:
> - [values-moderate.yaml](values-moderate.yaml)
> - [values-enhanced.yaml](values-enhanced.yaml)
> - [values-maximum.yaml](values-maximum.yaml)

## Examples

<details>
<summary><strong>Basic Installation</strong></summary>

```bash
helm install debug-shell ./deployments/helm/debug-shell \
  --set image.repository=ghcr.io/your-org/debug-shell \
  --set image.tag=v1.0.0
```
</details>

<details>
<summary><strong>Custom Namespace</strong></summary>

```bash
helm install debug-shell ./deployments/helm/debug-shell \
  --namespace debug-tools \
  --create-namespace
```
</details>

<details>
<summary><strong>Add SYS_PTRACE for strace</strong></summary>

```bash
helm install debug-shell ./deployments/helm/debug-shell \
  --set capabilities.add[1]=SYS_PTRACE
```
</details>

<details>
<summary><strong>Deployment Mode</strong></summary>

```bash
# Deploy as Deployment (instead of Pod)
helm install debug-shell ./deployments/helm/debug-shell \
  --set deploymentMode=deployment

# Deploy as DaemonSet
helm install debug-shell ./deployments/helm/debug-shell \
  --set deploymentMode=daemonset
```
</details>

<details>
<summary><strong>Custom Resource Limits</strong></summary>

```bash
helm install debug-shell ./deployments/helm/debug-shell \
  --set resources.limits.cpu=4 \
  --set resources.limits.memory=1Gi
```
</details>

## Tool Compatibility

| Tool | Moderate | Enhanced | Maximum |
|------|----------|----------|---------|
| `dig`, `nslookup`, `drill` | ✅ | ✅ | ✅ |
| `curl`, `wget` | ✅ | ✅ | ✅ |
| `netcat`, `netstat`, `ss`, `ip` | ✅ | ✅ | ✅ |
| `ping` | ✅ | ✅ | ❌ |
| `tcpdump` | ✅ | ✅ | ❌ |
| `nmap` | ✅ | ✅ | ❌ |
| `strace` | ✅* | ✅* | ❌ |

> [!NOTE]
> *Requires SYS_PTRACE capability (add via values or `--set`)

## Values Files

| File | Description |
|------|-------------|
| `values.yaml` | Default (moderate security) |
| `values-moderate.yaml` | Explicit moderate security |
| `values-enhanced.yaml` | Enhanced security with read-only filesystem |
| `values-maximum.yaml` | Maximum security, no capabilities |

## See Also

- [Kustomize Deployment](../../kustomize/base/README.md)
- [Deployment Plan](../../../docs/deployment-plan.md)
- [Security Hardening Guide](../../../docs/security-hardening.md)
- [Main README](../../../README.md)
