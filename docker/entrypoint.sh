#!/usr/bin/env bash
set -e
mkdir -p "$HOME"

# Fetch weights + demo data into the mounted repo on first run
if [ ! -d /workspace/weights ] && [ -z "$RAP_SKIP_DOWNLOAD" ]; then
    echo "[rap] ./weights not found, downloading weights and demo data..."
    bash /workspace/scripts/download_weights_and_demo_data.sh
fi

exec "$@"
