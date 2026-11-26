# Runner image for the homelab ARC scale set (homelab-infra platform/sandbox-arc). The official
# actions-runner image carries only the runner, the docker CLI, curl, jq, git and unzip; this adds the
# toolchains homelab jobs need, so jobs do not download them over the flaky WAN on every run. Unused
# images are reclaimed by kubelet's image GC, which a node-local tool cache would not be.
# Anything a job needs at a specific version still comes from actions/setup-* in that job.
FROM docker.io/library/node:24-bookworm-slim@sha256:873f586f3794f52281bd039bf02c048a0be08fde619338f9941bad1eb6b34530 AS node

FROM ghcr.io/actions/actions-runner:2.338.2@sha256:6d0b2d80d80f143f77dcb676e50920100bbb547e39e883454d57f45ab8c31300
LABEL org.opencontainers.image.source=https://github.com/ddupan/arc-runner-image

USER root
# Python for the TechDocs/mkdocs, Ansible and scripting jobs; zip/xz/make for release builds.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 python3-venv python3-pip python3-yaml \
       zip xz-utils make \
    && rm -rf /var/lib/apt/lists/*
# Node.js 24 with npm/npx/corepack, as the official node image lays it out (Ubuntu's nodejs is 18).
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx \
    && ln -s ../lib/node_modules/corepack/dist/corepack.js /usr/local/bin/corepack \
    && corepack enable \
    && node --version && npm --version && python3 --version

USER runner
