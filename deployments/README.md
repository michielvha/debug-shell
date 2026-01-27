# Debug Shell Deployments

We supply both a helmchart and kustomize method for deploying debug-shell in kubernetes

### Security Profiles

Three security profiles are available in all deployment options:

| Profile | Filesystem | Capabilities | Use Case |
|---------|-----------|--------------|----------|
| **Moderate** (default) | Writable | NET_RAW | Most users, simple deployments |
| **Enhanced** | Read-only | NET_RAW | Security-conscious production |
| **Maximum** | Read-only | None | Highly restricted environments |

> [!NOTE]
> See the [Security Hardening Guide](docs/security-hardening.md) for detailed information about each profile and tool compatibility.
