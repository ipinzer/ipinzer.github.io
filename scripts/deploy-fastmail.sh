#!/usr/bin/env bash
#
# Reliable Fastmail WebDAV deploy for the built `dist/` folder.
#
# Folder-drag uploads in the Fastmail web UI silently drop files when there
# are many of them. This script uploads every file individually over WebDAV
# with retries, then verifies nothing is missing.
#
# ---------------------------------------------------------------------------
# SETUP (one time):
#   1. Fastmail > Settings > Privacy & Security > App passwords > New app
#      password. Give it access to "Files (WebDAV/CalDAV/CardDAV)". Copy it.
#   2. Export credentials in your shell (they are never written to disk except
#      a temporary 0600 curl config that is deleted on exit):
#        export FM_USER="you@yourdomain"          # your full Fastmail login
#        export FM_PASS="the-app-password"
#
# USAGE:
#   # 1. Find the folder your website is served from:
#   ./scripts/deploy-fastmail.sh list
#   ./scripts/deploy-fastmail.sh list "/SomeFolder"      # drill into a folder
#
#   # 2. Deploy dist/ into that folder (example folder shown):
#   FM_TARGET="/izzy.pinzer.family" ./scripts/deploy-fastmail.sh deploy
#
# ---------------------------------------------------------------------------
set -euo pipefail

BASE="https://webdav.fastmail.com"
DIST="dist"

: "${FM_USER:?Set FM_USER to your Fastmail login email}"
: "${FM_PASS:?Set FM_PASS to a Fastmail app password (Files access)}"

# Write credentials to a temp curl config so the password never appears in
# the process list. Deleted on exit.
CFG="$(mktemp)"
chmod 600 "$CFG"
printf 'user = "%s:%s"\n' "$FM_USER" "$FM_PASS" > "$CFG"
trap 'rm -f "$CFG"' EXIT

curl_dav() { curl -sS -K "$CFG" "$@"; }

# URL-encode a path (keep slashes).
enc() {
  local s="$1" out="" c i
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9._~/-]) out+="$c" ;;
      *) out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  printf '%s' "$out"
}

cmd_list() {
  local path="${1:-/}"
  echo "Listing $BASE$path"
  curl_dav -X PROPFIND -H "Depth: 1" "$BASE$(enc "$path")" \
    | grep -oE '<[Dd]:href>[^<]+' | sed 's/<[Dd]:href>//' \
    | sed 's#^/*#/#' | sort -u
}

cmd_deploy() {
  local target="${FM_TARGET:?Set FM_TARGET to the website folder, e.g. /izzy.pinzer.family}"
  target="${target%/}"

  if [[ ! -d "$DIST" ]]; then
    echo "ERROR: '$DIST' not found. Run 'npm run build' first." >&2
    exit 1
  fi

  echo "==> Creating directories under $target ..."
  # Create target then every subdirectory (parents first).
  {
    echo "."
    (cd "$DIST" && find . -type d ! -name '.' | sort)
  } | while read -r d; do
    local rel="${d#./}"
    local remote="$target"
    [[ "$rel" != "." && -n "$rel" ]] && remote="$target/$rel"
    curl_dav -o /dev/null -X MKCOL "$BASE$(enc "$remote")" || true
  done

  echo "==> Uploading files ..."
  local total=0 fail=0 rel
  while IFS= read -r f; do
    rel="${f#"$DIST"/}"
    total=$((total + 1))
    if curl_dav --retry 4 --retry-delay 2 -f -o /dev/null \
        -T "$f" "$BASE$(enc "$target/$rel")"; then
      printf '.'
    else
      printf 'x'
      fail=$((fail + 1))
      echo " FAILED: $rel" >&2
    fi
  done < <(find "$DIST" -type f | sort)
  echo
  echo "==> Uploaded $((total - fail))/$total files ($fail failed)."

  echo "==> Verifying a sample of image files on the live site ..."
  local miss=0 checked=0 name code
  while IFS= read -r f; do
    name="$(basename "$f")"
    checked=$((checked + 1))
    code="$(curl -s -o /dev/null -w '%{http_code}' "https://izzy.pinzer.family/_astro/$name")"
    [[ "$code" == "200" ]] || { miss=$((miss + 1)); echo "  MISSING: $name ($code)"; }
  done < <(find "$DIST/_astro" -name '*.webp' | sort | awk 'NR%10==1')
  echo "==> Verify: $((checked - miss))/$checked sampled images present."
  if [[ "$fail" -eq 0 && "$miss" -eq 0 ]]; then
    echo "✅ Deploy complete."
  else
    echo "⚠️  Some files still missing — re-run 'deploy' to retry them."
  fi
}

case "${1:-}" in
  list) shift; cmd_list "${1:-/}" ;;
  deploy) cmd_deploy ;;
  *) echo "Usage: $0 {list [path] | deploy}"; exit 2 ;;
esac
