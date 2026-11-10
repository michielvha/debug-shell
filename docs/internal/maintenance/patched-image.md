# Maintenance: patched debug-shell image

Conventions: vhco-pro/docs@f781ee7b0404e80194aa568af3284888cc222017 (plugin pin); prose edited with guides/humanize-prose.md.

## Definition

Outcome: build a patched image with the selected dependency updates and working documented tools.

Preserved contract: the image runs as debug UID/GID 1000. DNS and HTTP tools work without capabilities, including read-only and no-privilege-escalation operation. Ping, packet capture and raw network scans use NET_RAW rather than root execution. The raw-tool Docker invocation uses file capabilities without no-new-privileges; no Kubernetes security setting changes. No registry publication, workflow dispatch or release is included.

Task base: `5312f8ef1b7a80456d99bd945a5c0ce926d7175c`, the locally committed unchanged bot updates from PRs #7, #8, #9 and #10.

Affected paths: `Dockerfile`, `tests/image-smoke.sh`, `.github/workflows/release.yml`, and the directly related tool-package and test instructions in `README.md`.

Verification inputs: those files, `.dockerignore`, the resolved Alpine 3.24.4 image index, installed Alpine packages, both workflow files, and the Helm chart with its security profiles.

Proposed change: pin the selected Alpine version to its observed multi-platform index digest, install the separate drill package, apply file capabilities to the actual ping/tcpdump/nmap binaries, remove ping's setuid bit, and leave BusyBox without file capabilities. Run image smoke tests in the existing pre-publication scan job.

Required checks:

- Observe the new image test fail on the selected unpatched image before implementation.
- Build the patched Linux amd64 image and run `bash tests/image-smoke.sh IMAGE`. Test non-root read-only DNS tool availability and local HTTP connectivity with no capabilities and no privilege escalation, then loopback ping/capture/raw scanning using Docker's documented NET_RAW/file-capability invocation. Separately observe real DNS queries in the hardened context.
- Run Trivy against the final image and fail on MEDIUM, HIGH or CRITICAL vulnerabilities, matching the existing release gate.
- Run `bash -n tests/image-smoke.sh`, `actionlint`, chart lint/templates for all configured profiles and deployment modes, and `git diff --check`.
- Obtain independent maintenance review of the exact source/record commit.

The local builder advertises amd64 only. ARM64 build/runtime validation and GitHub OIDC signing are unobserved, and are not represented as a delivered multi-platform release.

## Evidence

The selected unpatched image installs `ldns-tools`, which does not include `drill`. Alpine provides a separate `drill` package. Both the old and updated base images also install tcpdump at `/usr/bin/tcpdump`; the Dockerfile used `/usr/sbin/tcpdump` and ignored the failure.

BusyBox had `cap_net_raw=ep`, preventing basic applets from executing when NET_RAW was outside the capability bounding set. Ping was a separate iputils binary with a setuid bit, so assigning a capability to BusyBox did not repair ping.

Before implementation, `bash tests/image-smoke.sh debug-shell-maintenance:c6148905` exited 1 when the required drill executable was missing. The output is preserved in the session's `image-smoke-before.log`.

The observed Alpine 3.24.4 index digest is `sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf`. Its index includes amd64 and arm64 manifests.

Docker starts this non-root user with empty permitted/effective capabilities. Setting no-new-privileges also prevents acquiring NET_RAW through file capabilities, even when NET_RAW remains in the bounding set. Packet capture worked without that flag and failed with it. The basic hardened test retains the flag; the raw-diagnostic test uses the documented Docker capability invocation. No Kubernetes security setting was relaxed, and Kubernetes packet capture remains runtime-dependent and unverified.

The patched image was built from Dockerfile SHA-256 `d31ce4da0ecc38259df231770ba41932074f03b7fd7d7adf7303f24348a9ed05`. Local image `debug-shell:patched-c6148905` has ID `sha256:38c5052f86d6065e368f6d710516287c2ddb991778d693b41d8473b20da4fa01`, platform linux/amd64, and configured user `debug:debug`. This is a local image ID, not a published registry manifest digest.

On 2026-11-09, `bash tests/image-smoke.sh debug-shell:patched-c6148905` passed. Both contexts used UID 1000, read-only root filesystems and writable temporary directories. The capability-free context used no-new-privileges and exercised BusyBox applets, DNS executable availability and actual curl/wget HTTP responses served by netcat. The NET_RAW-only context captured loopback ICMP with tcpdump, received all three ping replies and completed a raw SYN nmap scan of loopback port 9.

A separate container using `--read-only --tmpfs /tmp --cap-drop ALL --security-opt no-new-privileges` successfully ran `dig +time=5 +tries=1 +short example.com A`, `drill example.com A`, and `nslookup example.com`. These real DNS checks used the host's network resolver; the committed smoke tests remain independent of external DNS/network services.

Trivy v0.70.0 scanned that exact image with the initialized session database, `--scanners vuln --image-src docker --severity MEDIUM,HIGH,CRITICAL --exit-code 1 --offline-scan --skip-db-update --skip-java-db-update`. It exited 0 with zero findings at those severities on Alpine 3.24.4. The raw JSON is session artifact `patched-trivy.json`. This release-threshold result does not assert an all-severity scan or complete the separate maintenance sweep's typed security accounting.

`bash -n tests/image-smoke.sh`, actionlint v1.7.12 on both workflows, `helm lint deployments/helm/debug-shell`, templates for moderate/enhanced/maximum profiles and pod/deployment/daemonset modes with Helm v3.20.0, and `git diff --check` all passed. Helm reported only its existing optional icon recommendation. ARM64 execution, Helm v4, GitHub OIDC signing and remote delivery were not observed.

## Reviews

### R-1

Target: `da8734a20296dfe95cdec2bb517a985754f09406`

Model: unknown

Isolation: procedural; independent general-purpose reviewer context, instructed read-only, with the canonical maintenance review protocol and pinned engineering references.

```text
NO FINDINGS
```

## State

Locally complete. The patched amd64 image is built and its required checks passed. Independent review returned no findings at the exact source/record commit above. This append-only review/state update does not change the Definition or verification inputs. No remote changes or publication have been performed.
