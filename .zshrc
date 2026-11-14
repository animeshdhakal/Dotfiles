HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_EXPIRE_DUPS_FIRST

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export VIRTUAL_ENV_DISABLE_PROMPT=1

export PATH="$HOME/bin:$HOME/.bin:$HOME/.local/bin:$HOME/.bun/bin:$PATH"

autoload -Uz compinit
compinit

alias ls='eza --icons=always'
alias ll='eza -lh --icons=always --git'
alias la='eza -lah --icons=always --git'
alias tree='eza --tree --icons=always'
alias cat='bat'
alias ..='cd ..'
alias ...='cd ../..'
alias vim='nvim'

rm() {
  local args=()
  for a; do
    [[ $a =~ ^-[rRfvi]+$ || $a =~ ^--(recursive|force)$ ]] || args+=("$a")
  done
  command trash "${args[@]}"
}

eval "$(zoxide init zsh --cmd cd)"

ZPLUGINDIR="$HOME/.local/zplugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

function zvm_after_init() {
  source <(fzf --zsh)
  eval "$(starship init zsh)"
}

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zdharma-continuum fast-syntax-highlighting
_zplugin_load jeffreytse zsh-vi-mode


function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}


start_vivado() {
  open -a XQuartz
  sleep 2
  DISPLAY=:0 /opt/X11/bin/xhost + localhost
  orb -m vivado bash -c "source /home/animesh/xilinx/2026.1/Vivado/settings64.sh && DISPLAY=host.orb.internal:0 LD_PRELOAD=/lib/x86_64-linux-gnu/libudev.so.1 vivado"
}

