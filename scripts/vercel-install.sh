#!/usr/bin/env bash
set -euo pipefail

FLUTTER_VERSION="3.47.9"
FLUTTER_SHA256="25ed8c3c29d51a7353f2a944310b478af8214920639524b19c50a19e6c044c5a"
FLUTTER_ROOT="${HOME}/flutter"

if [[ ! -x "${FLUTTER_ROOT}/bin/flutter" ]]; then
  archive="$(mktemp)"
  trap 'rm -f "$archive"' EXIT

  curl --fail --location --retry 3 \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    --output "$archive"
  echo "${FLUTTER_SHA256}  ${archive}" | sha256sum --check --status
  tar -xJf "$archive" -C "$HOME"
fi

git config --global --add safe.directory "$FLUTTER_ROOT"
"${FLUTTER_ROOT}/bin/flutter" config --enable-web
"${FLUTTER_ROOT}/bin/flutter" pub get
