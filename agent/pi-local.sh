#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
PI_BIN="$PROJECT_ROOT/.runtime/pi/node_modules/.bin/pi"
PI_STATE="$PROJECT_ROOT/.runtime/config"
PI_SESSIONS="$PROJECT_ROOT/.runtime/sessions"
PI_WORKSPACE="$PROJECT_ROOT/.runtime/workspace"

if [ ! -x "$PI_BIN" ]; then
  echo "Pi 尚未安装。先运行：./agent/install-pi.sh" >&2
  exit 1
fi

mkdir -p "$PI_STATE" "$PI_SESSIONS" "$PI_WORKSPACE"
cd "$PI_WORKSPACE"

export PI_CODING_AGENT_DIR="$PI_STATE"
export PI_CODING_AGENT_SESSION_DIR="$PI_SESSIONS"
export PI_TELEMETRY=0

exec "$PI_BIN" \
  --no-tools \
  --no-extensions \
  --no-skills \
  --no-prompt-templates \
  --no-themes \
  --no-context-files \
  "$@"
