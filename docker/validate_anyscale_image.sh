#!/usr/bin/env bash
set -euo pipefail

IMAGE=${1:-anyscale-cosmos-curate:latest}

ok() {
  printf '✅  %s\n' "$1"
}

fail() {
  printf '❌  %s\n' "$1"
  return 1
}

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    ok "$label"
  else
    fail "$label"
  fi
}

inspect() {
  docker image inspect --format "$1" "$IMAGE"
}

run_in_image() {
  docker run --rm --entrypoint /bin/bash "$IMAGE" -lc "$1"
}

status=0
printf '\nAnyscale Image Validation: %s\n\n' "$IMAGE"


# Platform / base
arch=$(inspect '{{.Os}}/{{.Architecture}}' || true)
if [ "$arch" = "linux/amd64" ]; then
  ok "platform is linux/amd64"
else
  fail "platform is linux/amd64 (got $arch)" || status=1
fi

os_version=$(run_in_image 'source /etc/os-release && echo "${VERSION_ID:-}"')
if [ "$os_version" = "22.04" ]; then
  ok "OS version is 22.04"
else
  fail "OS version is 22.04 (got $os_version)" || status=1
fi

# User / home / workdir
user=$(inspect '{{.Config.User}}' || true)
if [ "$user" = "ray" ]; then
  ok "default USER is ray"
else
  fail "default USER is ray (got '$user')" || status=1
fi

home=$(inspect '{{range .Config.Env}}{{println .}}{{end}}' | awk -F= '$1=="HOME"{print $2}' || true)
if [ "$home" = "/home/ray" ]; then
  ok "HOME is /home/ray"
else
  fail "HOME is /home/ray (got '$home')" || status=1
fi

workdir=$(inspect '{{.Config.WorkingDir}}' || true)
if [ "$workdir" = "/home/ray" ]; then
  ok "WORKDIR is /home/ray"
else
  fail "WORKDIR is /home/ray (got '$workdir')" || status=1
fi

# UID/GID and sudo
check "ray uid is 1000" run_in_image "id -u ray | grep -qx 1000" || status=1
check "ray gid is 100" run_in_image "id -g ray | grep -qx 100" || status=1
check "ray has passwordless sudo" run_in_image "sudo -n true" || status=1

# System binaries
for bin in sudo python ray bash sshd ssh rsync zip unzip git gdb curl; do
  check "binary on PATH: $bin" run_in_image "command -v $bin" || status=1
  done

# Python packages
check "python pkg: ray" run_in_image "python - <<'PY'\nimport ray\nPY" || status=1
check "python pkg: anyscale" run_in_image "python - <<'PY'\nimport anyscale\nPY" || status=1
check "python pkg: packaging" run_in_image "python - <<'PY'\nimport packaging\nPY" || status=1
check "python pkg: boto3" run_in_image "python - <<'PY'\nimport boto3\nPY" || status=1
check "python pkg: google" run_in_image "python - <<'PY'\nimport google\nPY" || status=1
check "python pkg: google-cloud-storage" run_in_image "python - <<'PY'\nfrom google.cloud import storage\nPY" || status=1
check "python pkg: terminado" run_in_image "python - <<'PY'\nimport terminado\nPY" || status=1

# Ray version >= 2.7
check "ray version >= 2.7" run_in_image "python - <<'PY'\nimport ray\nfrom packaging.version import Version\nassert Version(ray.__version__) >= Version('2.7.0')\nPY" || status=1

check "python pkg: jupyterlab" run_in_image "python - <<'PY'\nimport jupyterlab\nPY" || status=1

# Workspace bashrc behavior
check "PROMPT_COMMAND history -a in /home/ray/.bashrc" run_in_image "grep -q 'PROMPT_COMMAND=\"history -a\"' /home/ray/.bashrc" || status=1
check "workspacerc sourced in /home/ray/.bashrc" run_in_image "grep -q '\\[ -e ~/.workspacerc \\] && source ~/.workspacerc' /home/ray/.bashrc" || status=1

if [ $status -ne 0 ]; then
  printf '\n❌  One or more checks failed for %s\n' "$IMAGE"
  exit 1
fi

printf '\n✅  All checks passed for %s\n' "$IMAGE"
