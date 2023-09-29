fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
fish_add_path ~/.sage/local/bin

# early load tide_config
if test -f ~/.config/fish/tide_config.fish
    source ~/.config/fish/tide_config.fish
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

# check if the file exists
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

if status --is-interactive
    # note add AddKeysToAgent yes to ~/.ssh/config
    eval (keychain --eval --agents ssh,gpg --quiet --nogui -Q --timeout 45)

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
        alias cat "bat --paging=always"
    end

    if type -q yay
        alias yay "yay --sudoloop"
    end

    source ~/.config/fish/helpers/advanced_greeting.fish
end

# pnpm
set -gx PNPM_HOME "/home/main/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
