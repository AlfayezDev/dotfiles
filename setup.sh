#!/usr/bin/env bash
# Dotfiles bootstrap. Linux + macOS (bash 3.2+, plus: git, stow, jq).
#
#   1. seeds ~/.config/secrets/secrets from the tracked template (never overwrites)
#   2. stows the package tree (symlinks) — see .stow-local-ignore
#   3. rebuilds ~/.config/zed/settings.json = tracked template + local secrets,
#      written as a REAL file (not a symlink) so tokens can never reach the repo
#   4. writes Zed tasks with a macOS-only /bin/bash path adjustment
#   5. resets the repo worktree (undoes accidental stow --adopt writes)
#
# Zed installs every extension in auto_install_extensions on launch, so a
# fresh machine converges on the same editor automatically.
set -euo pipefail
cd "$(dirname "$0")"

for cmd in stow git jq nvim; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "missing dependency: $cmd (macOS: brew install $cmd)" >&2
    exit 1
  }
done

if ! nvim --headless -u NONE \
  "+lua if vim.fn.has('nvim-0.12') == 0 then vim.cmd('cquit') end" \
  '+qa' >/dev/null 2>&1; then
  echo "Neovim 0.12+ is required (macOS: brew upgrade neovim)." >&2
  exit 1
fi

if ! command -v tree-sitter >/dev/null 2>&1; then
  echo "tree-sitter CLI 0.26.1+ is required (macOS: brew install tree-sitter-cli)." >&2
  exit 1
fi

# 1. Local secrets: gitignored, one file per machine, plain `export VAR=`.
# Older installs linked the entire directory to the retired ./config tree.
# Replace that directory link without losing the machine-local secret file.
secrets_file="$HOME/.config/secrets/secrets"
secrets_backup=""
if [ -L "$HOME/.config/secrets" ]; then
  if [ -f "$secrets_file" ]; then
    secrets_backup="$(mktemp)"
    cp -p "$secrets_file" "$secrets_backup"
  fi
  rm "$HOME/.config/secrets"
fi
mkdir -p "$HOME/.config/secrets"
if [ -n "$secrets_backup" ]; then
  mv "$secrets_backup" "$secrets_file"
fi
if [ ! -f "$secrets_file" ]; then
  cp .config/secrets/secrets.template "$secrets_file"
  chmod 600 "$secrets_file"
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
settings_file="$HOME/.config/zed/settings.json"
settings_tmp="$(mktemp "$HOME/.config/zed/settings.json.XXXXXX")"
trap 'rm -f "$settings_tmp"' EXIT
jq \
  --arg sentry "${ZED_SENTRY_TOKEN:-}" \
  --arg kagi "${ZED_KAGI_API_KEY:-}" \
  '.context_servers["sentry-mcp"].settings.sentry_access_token = $sentry
   | .context_servers["kagimcp"].settings.kagi_api_key = $kagi' \
  .config/zed/settings.json > "$settings_tmp"
chmod 600 "$settings_tmp"
mv -f "$settings_tmp" "$settings_file"
trap - EXIT

# 4. Zed tasks: retain the tracked Linux path everywhere except macOS, where
# Bash is installed at /bin/bash. Keep the generated file outside the repo so
# one platform's absolute path cannot leak into another platform's dotfiles.
tasks_file="$HOME/.config/zed/tasks.json"
tasks_tmp="$(mktemp "$HOME/.config/zed/tasks.json.XXXXXX")"
trap 'rm -f "$tasks_tmp"' EXIT
if [ "$(uname -s)" = "Darwin" ]; then
  jq 'map(if .shell.with_arguments.program? == "/usr/bin/bash"
          then .shell.with_arguments.program = "/bin/bash"
          else . end)' \
    .config/zed/tasks.json > "$tasks_tmp"
else
  cp .config/zed/tasks.json "$tasks_tmp"
fi
chmod 600 "$tasks_tmp"
mv -f "$tasks_tmp" "$tasks_file"
trap - EXIT

# 5. Restore ownership of the dotfiles repo
git reset --hard

echo "Dotfiles installed successfully!"
