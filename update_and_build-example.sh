#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="../CLIProxyAPI"
BINARY="${REPO_DIR}/CLIProxyAPI"
ENTRY="${REPO_DIR}/cmd/server"

echo "========================================="
echo "  CLIProxyAPI  Pull & Build"
echo "========================================="

# ---- git pull ----
echo ""
echo "[1/3] git pull ..."
git -C "${REPO_DIR}" pull
echo ""

# ---- go mod download ----
echo "[2/3] go mod download ..."
cd "${REPO_DIR}"
go mod download
echo ""

# ---- build ----
VERSION="$(  git -C "${REPO_DIR}" describe --tags --always --dirty 2>/dev/null || echo dev)"
COMMIT="$(   git -C "${REPO_DIR}" rev-parse --short HEAD 2>/dev/null || echo none)"
BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "[3/3] go build ..."
echo "  Version:    ${VERSION}"
echo "  Commit:     ${COMMIT}"
echo "  Build Date: ${BUILD_DATE}"

CGO_ENABLED=0 go build \
  -ldflags="-s -w -X 'main.Version=${VERSION}' -X 'main.Commit=${COMMIT}' -X 'main.BuildDate=${BUILD_DATE}'" \
  -o "${BINARY}" \
  "${ENTRY}"

echo ""
echo "Build succeeded: ${BINARY}"
echo ""

# ---- restart if already running ----
OLD_PID="$(pgrep -f "${BINARY}" 2>/dev/null || true)"
if [[ -n "${OLD_PID}" ]]; then
  echo "Detected running CLIProxyAPI (PID ${OLD_PID}), restarting ..."
  kill "${OLD_PID}" 2>/dev/null || true
  sleep 1
  nohup "${BINARY}" >> "${REPO_DIR}/cliproxyapi.log" 2>&1 &
  echo "Restarted CLIProxyAPI (PID $!)"
else
  echo "No running CLIProxyAPI process found."
  echo "You can start it with:  ${BINARY}"
fi

echo ""
echo "Done."
