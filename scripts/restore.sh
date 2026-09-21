#!/usr/bin/env bash
set -euo pipefail
: "${DATABASE_URL:?DATABASE_URL is required}"
: "${1:?Usage: ./scripts/restore.sh backups/file.dump}"
DUMP="$1"
[ -f "$DUMP" ] || { echo "Backup not found: $DUMP" >&2; exit 1; }
if [ -f "$DUMP.sha256" ]; then sha256sum -c "$DUMP.sha256"; fi
pg_restore "$DATABASE_URL" --clean --if-exists --no-owner --exit-on-error "$DUMP"
echo "Restore completed from: $DUMP"
