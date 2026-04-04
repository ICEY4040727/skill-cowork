#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "[prepare_release] Root: $ROOT_DIR"

# Remove authoring research artifacts from release tree.
if [[ -d "$ROOT_DIR/research" ]]; then
  rm -rf "$ROOT_DIR/research"
  echo "[prepare_release] Removed: research/"
else
  echo "[prepare_release] Skipped: research/ (not found)"
fi

# Keep workspace folder, but remove runtime artifacts for a clean release.
if [[ -d "$ROOT_DIR/pr-review-workspace" ]]; then
  find "$ROOT_DIR/pr-review-workspace" -mindepth 1 ! -name "README.md" -exec rm -rf {} +
  echo "[prepare_release] Cleaned: pr-review-workspace/ (kept README.md)"
fi

# Remove transient Python cache files if present.
find "$ROOT_DIR" -type d -name "__pycache__" -prune -exec rm -rf {} +
find "$ROOT_DIR" -type f -name "*.pyc" -delete

echo "[prepare_release] Done."
