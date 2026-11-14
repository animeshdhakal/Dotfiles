# Dotfiles

My configuration files. The repo root holds the macOS setup; Linux Mint lives
in its own folder.

```
Dotfiles/
├── .config/          # macOS configs (nvim, ghostty, btop, yazi, yabai, skhd, ...)
├── .zshrc
├── .zprofile
├── .zshenv
├── .profile
├── .tcshrc
├── .tmux.conf
├── cp-files.sh       # macOS backup script
└── mint/             # Linux Mint setup (i3, zathura, nvim, tmux, wezterm, ...)
```

The root mirrors `$HOME`, so `.zshrc` belongs at `~/.zshrc` and
`.config/nvim/init.lua` at `~/.config/nvim/init.lua`.

## Backing up this machine

### macOS

```sh
cd ~/Dotfiles
./cp-files.sh          # copy configs from $HOME into the repo root
./cp-files.sh --push   # copy, commit and push in one go
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
cp -r ~/Dotfiles/. ~/        # macOS
cp -r ~/Dotfiles/mint/. ~/   # Linux Mint
```

Review the contents before running anything, then restart your shell/apps.
