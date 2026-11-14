# Dotfiles

My configuration files, split per machine/OS.

```
Dotfiles/
├── mint/   # Linux Mint setup (i3, zathura, nvim, tmux, wezterm, ...)
└── mac/    # macOS setup (zsh, ghostty, btop, yazi, yabai, skhd, nvim, ...)
```

Each folder mirrors `$HOME`, so a file at `mac/.zshrc` belongs at `~/.zshrc`
and `mint/.config/i3/config` belongs at `~/.config/i3/config`.

## Backing up this machine

### macOS

```sh
cd ~/Dotfiles
./mac/cp-files.sh          # copy configs from $HOME into mac/
./mac/cp-files.sh --push   # copy, commit and push in one go
```

The script copies a curated list of files/directories (see the `FILES` and
`DIRS` arrays at the top of the script — add or remove entries as needed) and
skips machine-local state and secrets such as `.DS_Store`, `service.json` and
`*.mmdb`.

### Linux Mint

```sh
cd ~/Dotfiles/mint
./cp-files.sh
```

Run it from inside `mint/` so the relative `./.config` targets land in the repo.

## Restoring on a new machine

Copy the files back into place from the matching folder, e.g.

```sh
cp -r ~/Dotfiles/mac/. ~/
# or, on Mint
cp -r ~/Dotfiles/mint/. ~/
```

Review the contents before running anything, then restart your shell/apps.
