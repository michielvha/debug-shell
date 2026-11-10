# Maintenance: pinned release actions

Conventions: vhco-pro/docs@f781ee7b0404e80194aa568af3284888cc222017 (plugin pin); prose edited with guides/humanize-prose.md.

## Definition

Outcome: after the owner's repository recreation, use current verified action revisions at full commit SHAs, remove the repository-specific GitVersion configuration, and use the shared action's bundled defaults with v-prefixed Git tags.

Task base: `e070ac3fcb251f9cf1286bc2a228343c3ce96640`.

Preserved contract: keep the existing image/chart release paths, non-root image behavior, scan/smoke gates and GitHub OIDC signing. No shared action repositories or package permissions are changed. All commit authorship remains human or existing upstream bots; AI attribution is prohibited.

Affected paths: `.github/workflows/release.yml`, `.github/workflows/helm-release.yml`, deletion of `gitversion.yml`, and directly related release-versioning instructions in `README.md`.

Verification inputs: those files, both workflow manifests, image smoke test and Dockerfile, Helm chart/profile inputs, repository Git history/tags, and the exact selected shared-action manifests and bundled GitVersion configuration.

Proposed change: replace all 13 direct action uses with verified executable commit SHAs. Advance Trivy action from v0.35.0 to v0.36.0. Freeze otherwise current action interfaces without adding new permissions. Use released GitVersion action v7.0.4, whose runtime/config matches current main. Preserve docker-release-action's existing current main revision because its unreleased Trivy installer fixes would be lost by choosing its older v2 tag; label this SHA truthfully as an unreleased snapshot. Delete both configFilePath overrides and the repository config, set prefix v in both workflows, and use the shared semVer output consistently.

Required checks:

- Observe current source fail the full-SHA/config-removal requirements before changes.
- Assert every direct workflow action ref has exactly 40 hexadecimal commit characters, both workflows select prefix v without configFilePath, and gitversion.yml is absent.
- Verify selected release refs resolve to executable commits, with compatible action inputs/outputs and truthful release comments.
- Run actionlint, Bash smoke-test syntax, Helm lint and all security-profile/deployment-mode templates, and git diff --check.
- Run GitVersion 6.8.0 with the exact bundled configuration against a full-history simulated main merge of the committed source. Observe the computed next semantic version, without publishing tags.
- Preserve existing image inputs and validate the previously published image remains accessible. Obtain independent maintenance review at the exact source/record commit before publication.

Delivery sequence: after independent review, publish one clean PR, observe applicable CI, merge normally under the owner's continuing rollout request, and observe the resulting image/chart release. Package linkage/access must be restored before claiming a completed release.

## Evidence

The original repository was recreated as ID `1452050280`, preserving all 35 cleaned commits and all 18 original branch/tag object IDs. Original PR #11 now returns 404. The replacement's contributors API lists only michielvha and renovate[bot]. User-level includeCoAuthoredBy remains false.

Before changes, the explicit shape check reported floating direct refs, both config overrides and the existing repository GitVersion file. After changes, it passes for all 13 refs, bundled config selection and v-prefix selection. Actionlint v1.7.12, chart lint, all moderate/enhanced/maximum profiles and pod/deployment/daemonset modes with Helm v3.20.0, and whitespace checks passed.

Selected executable pins, verified against upstream refs and action manifests:

| Action | Selected revision | Executable commit |
| --- | --- | --- |
| actions/checkout | v7.0.1 | 3d3c42e5aac5ba805825da76410c181273ba90b1 |
| azure/setup-helm | v5.1.0 | 2f5e7bc67f1f9972ab16657bb795f36d8f04de0e |
| docker/build-push-action | v7.4.0 | c3c9e263c25d99ce0380d002d59b67737d91b0dc |
| aquasecurity/trivy-action | v0.36.0 | ed142fd0673e97e23eac54620cfb913e5ce36c25 |
| github/codeql-action/upload-sarif | v4.39.3 | 33d7b85da1a04171e211befe2c739303b9a4c066 |
| michielvha/gitversion-tag-action | v7.0.4 | 8cf5869816cf71437052ac97d086e00526bf2d89 |
| michielvha/docker-release-action | unreleased main snapshot | 066309e6b93a8304d96f6f301b9d972f5e43f6d7 |
| sigstore/cosign-installer | v4.1.3 | 756fe2d284c7292c4e9b62c8a28f1e5629c59532 |
| michielvha/helm-oci-publish-action | v0.1.5 tag | 922e3ba68b68a1d6e183e50cfb4879294ff781f7 |

The CodeQL repository's latest overall release is a tool bundle; the selected v4.39.3 release is the latest action release. Helm publishing has a v0.1.5 tag but no matching GitHub release. The GitVersion v7.0.4 tag was peeled to its commit; current main differs only in the action repository's own release workflow.

The action's bundled configuration has Git blob ID `d4eddd65b930fd569654f686e646e33ae366846a`. Its installer selects GitVersion 6.8.0. The official linux-x64 release archive was verified against its independently fetched release-asset SHA-256 `8e7ede2369fb8138b40d3831a36bcddfee5836c840f749b9d604788a44c260f9`.

The verified GitVersion executable reports `6.8.0+Branch.main.Sha.cf6a76c393a467678f773cab4bc8eb924f6076b7`. A full-history disposable clone simulated a main merge of source commit `8fdf1aceb11e08d323196f8f10e09c6e096d01b6`, with the intended chore merge message. Running that binary with the exact bundled file and `/output json /nofetch /nonormalize` returned SemVer and FullSemVer `0.6.6`, BranchName `main`, and VersionSourceSha `c8bf53d95e2995dd6cefe673b6404cf71a4868fb`. This establishes the expected `v0.6.6` Git tag and `0.6.6` artifact versions using the existing prefixed/unprefixed baseline, without creating any remote tag.

The existing public image `ghcr.io/michielvha/debug-shell:0.6.5` remains accessible at index digest `sha256:f17b499197edea5ce7a90350fbd6bf1f07b6f8b6c8b1b2bdaf347c4235c32813`. The task does not change its Dockerfile or runtime smoke test.

Pinning these direct action refs does not freeze floating nested refs inside upstream composite actions. Those upstream repositories are outside this task's write scope.

Recreation left the existing public GHCR image and chart packages intact but disconnected from the repository. Their repository fields are null. The owner must reconnect package access before release success can be claimed; no credential scope or package access was silently changed. GitHub App access after recreation is also unverified because installation enumeration was denied.

## Reviews

### R-1

Target: `0932439997d9742332dd89ac0620d6d121e46258`

Model: unknown

Isolation: procedural; independent read-only reviewer context with the canonical maintenance review protocol and pinned engineering references.

```text
FINDING: F-01
KIND: factual
SEVERITY: nit
WHERE: `.github/workflows/release.yml:115`
EVIDENCE: The pinned action declares `semVer`; other workflow references use `.semVer`, but the image-reference display uses `.semver`. The maintenance record calls for consistent use of `semVer`.
PROPOSAL: Change the display reference to `.semVer` to match the declared output and the other workflow references.
```

F-01 is addressed in the following source revision by consistently using semVer in the display output. Re-review pending.

## State

Active. Local verification passed, including the bundled version calculation. Exact-commit review and remote delivery remain pending.
