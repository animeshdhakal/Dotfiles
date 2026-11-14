#!/usr/bin/env bash
#
# Back up this Mac's config files into the root of the Dotfiles repo.
#
# Usage:
#   ./cp-files.sh          # copy files into the repo
#   ./cp-files.sh --push   # copy, commit and push in one go

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="$HOME"

# Single files, relative to $HOME
FILES=(
  ".zshrc"
  ".zprofile"
  ".zshenv"
  ".profile"
  ".tcshrc"
  ".tmux.conf"
  ".inputrc"
  ".clang-format"
  ".config/starship.toml"
)

# Directories, relative to $HOME (copied recursively, mirroring deletions)
DIRS=(
  ".bin"
  ".config/nvim"
  ".config/ghostty"
  ".config/btop"
  ".config/yazi"
  ".config/yabai"
  ".config/skhd"
  ".config/neru"
  ".config/opencode"
  ".config/asm-lsp"
  ".config/trippy"
)

# Never copy these (machine-local state, secrets, binaries)
EXCLUDES=(
  ".DS_Store"
  "service.json"
  "*.mmdb"
  "*.log"
  "lazy-lock.json"
)

copied=0
skipped=0

for f in "${FILES[@]}"; do
  src="$HOME_DIR/$f"
  if [ ! -f "$src" ]; then
    printf 'skip   %s (not found)\n' "$f"
    skipped=$((skipped + 1))
    continue
  fi
  dest="$REPO_DIR/$f"
  mkdir -p "$(dirname "$dest")"
  cp -p "$src" "$dest"
  printf 'copied %s\n' "$f"
  copied=$((copied + 1))
done

for d in "${DIRS[@]}"; do
  src="$HOME_DIR/$d"
  if [ ! -d "$src" ]; then
    printf 'skip   %s (not found)\n' "$d"
    skipped=$((skipped + 1))
    continue
  fi
  dest="$REPO_DIR/$d"
  mkdir -p "$dest"
  rsync_args=(-aL --delete)
  for e in "${EXCLUDES[@]}"; do
    rsync_args+=("--exclude=$e")
  done
  rsync "${rsync_args[@]}" "$src/" "$dest/"
  printf 'copied %s/\n' "$d"
  copied=$((copied + 1))
done

printf '\n%d item(s) copied, %d skipped.\n' "$copied" "$skipped"

if [ "${1:-}" = "--push" ]; then
  cd "$REPO_DIR"
  git add -A .
  if git diff --cached --quiet; then
    echo "Nothing to commit, repo already up to date."
  else
    git commit -m "Update mac dotfiles ($(date +%Y-%m-%d))"
    git push
  fi
else
  cat <<EOF

Next steps:
  cd "$REPO_DIR"
  git add -A .
  git commit -m "Update mac dotfiles"
  git push

Or do it all at once:
  "$REPO_DIR/cp-files.sh" --push
EOF
fi
