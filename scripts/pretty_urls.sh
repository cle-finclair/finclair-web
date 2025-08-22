#!/usr/bin/env bash
set -euo pipefail

# Detect macOS vs GNU sed
SED_INLINE=()
if sed --version >/dev/null 2>&1; then
  # GNU sed
  SED_INLINE=(-i)
else
  # macOS/BSD sed
  SED_INLINE=(-i '')
fi

# Loop over top-level *.html files
for f in *.html; do
  [ "$f" = "index.html" ] && continue
  name="${f%.html}"
  mkdir -p "$name"
  git mv "$f" "$name/index.html"

  # Redirect stub for old /page.html
  cat > "$name.html" <<EOF
<!doctype html><meta charset="utf-8">
<meta http-equiv="refresh" content="0; url=/${name}/">
<link rel="canonical" href="/${name}/">
<title>Redirecting…</title>
<a href="/${name}/">Redirecting to /${name}/</a>
<script>location.replace('/${name}/');</script>
EOF
  git add "$name.html"
done

# Update links in all .html files
find . -type f -name "*.html" ! -path "./node_modules/*" -print0 | \
  xargs -0 sed "${SED_INLINE[@]}" \
    -e 's/\.html"/\/"/g' \
    -e 's/\.html#/#/g' \
    -e 's/\.html?/\//g'

echo "✅ Done. Review with: git status"
