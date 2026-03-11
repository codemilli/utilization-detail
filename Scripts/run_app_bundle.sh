#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_PATH="${ROOT_DIR}/Build/Utilization Detail.app"

"${ROOT_DIR}/Scripts/build_app.sh" >/dev/null
open "${APP_PATH}"

echo "Opened ${APP_PATH}"
