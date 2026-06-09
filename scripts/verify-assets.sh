#!/usr/bin/env bash
# Verify npm run build:assets wrote prod bundles that match header.php inject tags.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

HREF="$(grep -oP 'href="\Kresources/opensourcepos-[a-f0-9]+\.min\.css' app/Views/partial/header.php || true)"

if [[ -z "$HREF" ]]; then
    echo "FAIL: no prod CSS href in app/Views/partial/header.php (run npm run build:assets first)" >&2
    exit 1
fi

ASSET="public/${HREF}"

if [[ ! -f "$ASSET" ]]; then
    echo "FAIL: header references ${HREF} but file missing at ${ASSET}" >&2
    echo "Hint: use public/\${HREF} — bundles live under public/resources/, not public/ root" >&2
    exit 1
fi

if ! grep -q 'module_item' "$ASSET"; then
    echo "FAIL: ${ASSET} missing home layout rules (module_item)" >&2
    exit 1
fi

echo "OK: prod CSS ${HREF} ($(wc -c < "$ASSET" | tr -d ' ') bytes, layout rules present)"
