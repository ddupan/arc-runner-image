# arc-runner-image

Runner image for the homelab ARC scale set `homelab` (homelab-infra `platform/sandbox-arc`):
`ghcr.io/actions/actions-runner` plus Python 3 (venv, pip, PyYAML), Node.js 24 (npm, npx, corepack),
zip, xz and make.

The official runner image has no toolchains, and installing them per job means downloading them over
the homelab's flaky WAN every time. A node-local tool cache was rejected because nothing would ever
clean it; images are reclaimed by kubelet's image GC.

`main` publishes `ghcr.io/ddupan/arc-runner:latest`; homelab-infra pins it by digest, so a new image
takes effect only when that pin is bumped. Add a tool here only when several homelab jobs need it;
a job-specific version belongs in that job's `actions/setup-*`.
