if test -d ~/.cargo/bin
  fish_add_path ~/.cargo/bin
end

if test -d ~/go
  set -x GOPATH ~/go
end

if test -d ~/go/bin
  fish_add_path ~/go/bin
end

if test -d ~/.local/bin
  fish_add_path ~/.local/bin
end

if test -d ~/.sage/local/bin
  fish_add_path ~/.sage/local/bin
end

if test -d ~/.nix-profile/bin
  fish_add_path ~/.nix-profile/bin
end

if type -q pyenv
  set -x PYENV_ROOT $HOME/.pyenv
  fish_add_path $PYENV_ROOT/bin
  pyenv init - | source
end

if type -q npm
  set -x NPM_CONFIG_PREFIX $HOME/.npm-global
  fish_add_path $NPM_CONFIG_PREFIX/bin
end

if type -q flatpak
  # test if these paths are already in XDG_DATA_DIRS
  if not string match -q -- ~/.local/share/flatpak/exports/share $XDG_DATA_DIRS
    set -x XDG_DATA_DIRS $XDG_DATA_DIRS:~/.local/share/flatpak/exports/share
  end
  if not string match -q -- /var/lib/flatpak/exports/share $XDG_DATA_DIRS
    set -x XDG_DATA_DIRS $XDG_DATA_DIRS:/var/lib/flatpak/exports/share
  end
end

for f in ~/.config/fish/tdcff_functions/*.fish
  #echo "sourcing $f"
  source $f
end

if grep -qi microsoft /proc/version;
  and grep -qi "Arch Linux" /etc/os-release
  # bass source /etc/profile.d/debuginfod/archlinux.urls
  # https://bbs.archlinux.org/viewtopic.php?id=276422
  # fixes valgrind
  set -x DEBUGINFOD_URLS "https://debuginfod.archlinux.org"
end

# check if a machine specific config exists
if test -f ~/.config/fish/machine-config.fish
  source ~/.config/fish/machine-config.fish
end

if not set -q CPM_SOURCE_CACHE
  set -x CPM_SOURCE_CACHE ~/.cpm_source_cache
end

# check if podman is installed
if type -q podman
  if test -S "$XDG_RUNTIME_DIR/podman/podman.sock"
    set -x DOCKER_HOST "unix://$XDG_RUNTIME_DIR/podman/podman.sock"
  end
end

# check if miniconda is installed
if test -d ~/miniconda3
  source ~/miniconda3/etc/fish/conf.d/conda.fish
end

if type -q keychain && tdc_is_proper_user
  # To make keychain available in plasma:

  ## nano $HOME/.config/plasma-workspace/env/keychain.sh
  #!/bin/bash
  #keychain --quiet --nogui -Q --timeout 45
  #[ -z "$HOSTNAME" ] && HOSTNAME=`uname -n`
  #[ -f $HOME/.keychain/$HOSTNAME-sh ] && \
  #. $HOME/.keychain/$HOSTNAME-sh
  #[ -f $HOME/.keychain/$HOSTNAME-sh-gpg ] && \
  #. $HOME/.keychain/$HOSTNAME-sh-gpg

  # note add AddKeysToAgent yes to ~/.ssh/config
  keychain --eval --quiet --nogui -Q --timeout 45 | source
end

# enable bake for better build performance in docker-compose
set -x COMPOSE_BAKE true

if status --is-interactive
  if test -n "$EDITOR"
    if type -q nano
      set -l nano_full_path (command -v nano)
      set -x EDITOR "$nano_full_path"
      set -x VISUAL "$nano_full_path"
    else if type -q nvim
      set -l nvim_full_path (command -v nvim)
      set -x EDITOR "$nvim_full_path"
      set -x VISUAL "$nvim_full_path"
    else if type -q vim
      set -l vim_full_path (command -v vim)
      set -x EDITOR "$nvim_full_path"
      set -x VISUAL "$nvim_full_path"
    end
  end

  if type -q nvim
    alias vi nvim
    alias vim nvim
  else if type -q vim
    alias vi vim
  end

  # use eza if available the eza tree command is much faster than lsd tree
  if type -q eza
    alias ls "eza --icons"
    alias la "eza --icons -a"
    alias tree "eza --icons --tree"
  else if type -q lsd
    alias ls "lsd --icon always"
    alias la "lsd --icon always -a"
    alias tree "lsd --icon always --tree"
  else
    alias ls "ls --color=auto"
    alias la "ls --color=auto -a"
    alias tree "tree -C"
  end

  if type -q bat
    alias cat "bat --paging=never --plain"
  end

  if type -q yay
    alias yay "yay --sudoloop"
  end

  if type -q zoxide
    zoxide init fish | source
  end

  if type -q sudoedit
    # https://github.com/microsoft/vscode-remote-release/issues/1688#issuecomment-1708577380
    if type -q code
      alias sudocode 'SUDO_EDITOR="$(which code) --wait" sudoedit'
    end
    if type -q code-insiders
      alias sudocode-insiders 'SUDO_EDITOR="$(which code-insiders) --wait" sudoedit'
    end
  end

  source ~/.config/fish/helpers/advanced_greeting.fish
end
