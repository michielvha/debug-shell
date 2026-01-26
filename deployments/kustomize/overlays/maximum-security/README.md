# Maximum Security Overlay

Maximum security restrictions with **no capabilities** and strict resource limits.

> [!WARNING]
> **This configuration disables several tools** that require Linux capabilities:
> - `ping` (requires NET_RAW)
> - `tcpdump` (requires NET_RAW)
> - `nmap` (requires NET_RAW)
> - `strace` (requires SYS_PTRACE)

> [!IMPORTANT]
> Only use this overlay if:
> - You're in a highly restricted environment
> - You have compliance requirements that mandate no capabilities
> - You don't need the disabled tools
> - You understand the limitations

## Security Profile

| Feature | Status |
|---------|--------|
| Non-root user | ✅ |
| Read-only filesystem | ✅ |
| **No capabilities** | ✅ (ALL dropped) |
| No privilege escalation | ✅ |
| Resource limits | ✅ (stricter) |
| Volume mounts | ✅ |

## Quick Start

```bash
kubectl apply -k deployments/kustomize/overlays/maximum-security
kubectl exec -it debug-shell -- /bin/bash
```

## Tool Availability

### ✅ Available Tools

| Category | Tools |
|---------|-------|
| **DNS** | `dig`, `nslookup`, `drill` |
| **HTTP** | `curl`, `wget` |
| **Network** | `netcat`, `netstat`, `ss`, `ip` (read-only) |
| **Scripts** | Can write to `/tmp`, `/var/tmp`, `/home/debug` |

### ❌ Disabled Tools

| Tool | Reason | Alternative |
|------|--------|------------|
| `ping` | Requires NET_RAW | `curl -v --connect-timeout 5 http://example.com` |
| `tcpdump` | Requires NET_RAW | Application-level logging |
| `nmap` | Requires NET_RAW | `nc -zv` for port testing |
| `strace` | Requires SYS_PTRACE | Application-level debugging |

## Workarounds

<details>
<summary><strong>Instead of <code>ping</code></strong></summary>

```bash
# Use curl for connectivity testing
curl -v --connect-timeout 5 http://example.com

# Or use netcat for port testing
nc -zv example.com 80
```
</details>

<details>
<summary><strong>Instead of <code>nmap</code></strong></summary>

```bash
# Use netcat for port scanning
for port in {1..1000}; do
  nc -zv -w 1 hostname $port 2>&1 | grep succeeded
done

# Or use curl for HTTP testing
curl -v http://example.com:80
```
</details>

<details>
<summary><strong>Instead of <code>tcpdump</code></strong></summary>

Packet capture is not available without NET_RAW. Use application-level logging or monitoring tools instead.
</details>

<details>
<summary><strong>Instead of <code>strace</code></strong></summary>

Process tracing is not available without SYS_PTRACE. Use application-level debugging tools instead.
</details>

## Use Cases

| ✅ Suitable For | ❌ NOT Suitable For |
|----------------|---------------------|
| Highly restricted environments | General debugging |
| Compliance (PCI-DSS, HIPAA) | Network troubleshooting |
| Security-first deployments | Development environments |
| When ping/tcpdump/nmap not needed | Most production debugging |

## Resource Limits

| Resource | Limit | Request |
|----------|-------|---------|
| **CPU** | 1 core | 100m |
| **Memory** | 256Mi | 128Mi |

Stricter than base configuration.

## Comparison

| Feature | Base | Enhanced | Maximum |
|---------|------|----------|---------|
| Non-root user | ✅ | ✅ | ✅ |
| NET_RAW capability | ✅ | ✅ | ❌ |
| Read-only filesystem | ❌ | ✅ | ✅ |
| No capabilities | ❌ | ❌ | ✅ |
| `ping` works | ✅ | ✅ | ❌ |
| `tcpdump` works | ✅ | ✅ | ❌ |
| `nmap` works | ✅ | ✅ | ❌ |
| All DNS tools | ✅ | ✅ | ✅ |
| All HTTP tools | ✅ | ✅ | ✅ |

## Migration Guide

<details>
<summary><strong>Need ping/tcpdump/nmap?</strong></summary>

1. Switch to [enhanced-security overlay](../enhanced-security/) (keeps NET_RAW)
2. Or use [base configuration](../../base/) (simpler)
</details>

<details>
<summary><strong>Need strace?</strong></summary>

1. Add SYS_PTRACE capability to [enhanced-security overlay](../enhanced-security/)
2. See enhanced-security README for instructions
</details>

## Troubleshooting

<details>
<summary><strong>Tool not working?</strong></summary>

- Check the "Tool Availability" section above
- Verify the tool doesn't require capabilities
- Use workarounds provided above
</details>

<details>
<summary><strong>Need more tools?</strong></summary>

- Consider using [enhanced-security overlay](../enhanced-security/) instead
- Or use [base configuration](../../base/) for maximum compatibility
</details>

## See Also

- [Base Configuration](../../base/README.md)
- [Enhanced Security Overlay](../enhanced-security/README.md)
- [Deployment Plan](../../../../docs/deployment-plan.md)
- [Security Hardening Guide](../../../../docs/security-hardening.md)
