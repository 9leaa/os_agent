#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

# shellcheck disable=SC1091
. "$SCRIPT_DIR/versions.env"

node_major=$(node -p 'process.versions.node.split(".")[0]')
node_minor=$(node -p 'process.versions.node.split(".")[1]')
required_major=${NODE_MIN_VERSION%%.*}
required_minor=${NODE_MIN_VERSION#*.}
required_minor=${required_minor%%.*}

if [ "$node_major" -lt "$required_major" ] || {
  [ "$node_major" -eq "$required_major" ] && [ "$node_minor" -lt "$required_minor" ]
}; then
  echo "需要 Node.js >= $NODE_MIN_VERSION，当前为 $(node --version)。" >&2
  exit 1
fi

npm install \
  --prefix "$PROJECT_ROOT/.runtime/pi" \
  --ignore-scripts \
  --no-save \
  "@earendil-works/pi-coding-agent@$PI_VERSION"

"$PROJECT_ROOT/.runtime/pi/node_modules/.bin/pi" --version
