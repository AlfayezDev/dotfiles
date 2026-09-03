#!/usr/bin/env bash
# Dotfiles bootstrap. Linux + macOS (bash 3.2+, plus: git, stow, jq).
#
#   1. seeds ~/.config/secrets/secrets from the tracked template (never overwrites)
#   2. stows the package tree (symlinks) — see .stow-local-ignore
#   3. rebuilds ~/.config/zed/settings.json = tracked template + local secrets,
#      written as a REAL file (not a symlink) so tokens can never reach the repo
#   4. resets the repo worktree (undoes accidental stow --adopt writes)
#
# Zed installs every extension in auto_install_extensions on launch, so a
# fresh machine converges on the same editor automatically.
set -euo pipefail
cd "$(dirname "$0")"

for cmd in stow git jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "missing dependency: $cmd (macOS: brew install $cmd)" >&2
    exit 1
  }
done

# 1. Local secrets: gitignored, one file per machine, plain `export VAR=`
mkdir -p "$HOME/.config/secrets"
if [ ! -f "$HOME/.config/secrets/secrets" ]; then
  cp .config/secrets/secrets.template "$HOME/.config/secrets/secrets"
  chmod 600 "$HOME/.config/secrets/secrets"
  echo "Seeded ~/.config/secrets/secrets — fill in your tokens, then re-run."
fi

# 2. Stow with adopt flag to overwrite existing files
./stow.sh

# 3. Zed settings: tracked template + secrets -> real file
set -a
# shellcheck disable=SC1091
. "$HOME/.config/secrets/secrets"
set +a
mkdir -p "$HOME/.config/zed"
jq \
  --arg sentry "${ZED_SENTRY_TOKEN:-}" \
  --arg kagi "${ZED_KAGI_API_KEY:-}" \
  '.context_servers["sentry-mcp"].settings.sentry_access_token = $sentry
   | .context_servers["kagimcp"].settings.kagi_api_key = $kagi' \
  .config/zed/settings.json > "$HOME/.config/zed/settings.json"
chmod 600 "$HOME/.config/zed/settings.json"

# 4. Restore ownership of the dotfiles repo
git reset --hard

echo "Dotfiles installed successfully!"
