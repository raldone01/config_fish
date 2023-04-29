fish_add_path ~/.cargo/bin
fish_add_path ~/.local/bin
fish_add_path ~/.sage/local/bin

if grep -qi microsoft /proc/version;
    and grep -qi "Arch Linux" /etc/os-release
    # bass source /etc/profile.d/debuginfod/archlinux.urls
    # https://bbs.archlinux.org/viewtopic.php?id=276422
    # fixes valgrind
    set -x DEBUGINFOD_URLS "https://debuginfod.archlinux.org"
end

# don't forget to create this file
source ~/.config/fish/machine-config.fish

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

    alias ls "exa --icons"
    alias la "exa --icons -a"
    alias tree "exa --icons --tree"
    alias yay "yay --sudoloop"

    function rand_pic_file
        set -g last_pic_file (find $pic_folders -type f \( -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) | shuf -n 1)
        echo $last_pic_file

        function pic_not_nice
            rm -i "$last_pic_file"
            functions -e pic_not_nice
        end
    end

    function calm
        set -l rand_pic_file (rand_pic_file)
        set -l filename (basename $rand_pic_file)
        echo "Featured pic $filename (Run pic_not_nice to delete)"
        image_viewer $argv $rand_pic_file
    end

    function update
        echo "Updating system packages..."
        if grep -qi "Arch Linux" /etc/os-release
            yay --sudoloop -Syu
        else if grep -qi Debian /etc/os-release
            echo "Running apt-get update && apt-get upgrade"
            sudo fish -c "apt-get update && apt-get upgrade"
        else
            echo "Failed to update system packages."
            echo "Unknown system package manager or distribution."
        end
        if type -q rustup
            echo "Updating rustup..."
            rustup self update
            echo "Updating the rust toolchain..."
            rustup update
        end
        # https://stackoverflow.com/a/66049504/4479969
        if type -q cargo
            echo "Updating the crates installed with 'cargo install'..."
            cargo install $(cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')
        end
        if type -q fisher
            echo "Updating the fisher fish plugins..."
            fisher update
        end
        if type -q flatpak
            echo "Updating the installed flatpaks..."
            flatpak update
        end
    end

    function fish_greeting
        set -l rand_pic_file (rand_pic_file)
        set -l terminal_height (tput lines)
        set -l terminal_width (tput cols)

        function internal_before_pic_text -S
            # print login message

            if test $terminal_width -gt 134;
                or test $terminal_height -lt 53
                #print it in one line
                set date_str (date +"%d/%b/%Y %H:%M:%S")
            else
                # print it in two lines
                set date_str "$(printf "%s\n%s" (date +"%d/%b/%Y") (date +"%H:%M:%S"))"
            end

            if test $terminal_width -gt 77;
                and test $terminal_height -gt 40
                printf "%s" $date_str | figlet -t | boxes -d scroll
            else
                printf "%s\n" $date_str
            end

            echo "Use calm to calm. Powered by fish the friendly interactive shell."
            set -l filename (basename $rand_pic_file)
            echo "Featured pic $filename (Run pic_not_nice to delete)"
        end
        function internal_after_pic_text -S
        end
        set -l before_pic_text (internal_before_pic_text)
        set -l after_pic_text (internal_after_pic_text)

        set -l before_lines (printf "%s\n" $before_pic_text | wc -l)
        set -l after_lines (printf "%s\n" $after_pic_text | wc -l)

        # echo "$terminal_height $before_lines $after_lines"
        set -l image_height (math $terminal_height - $before_lines - $after_lines)
        printf "%s\n" $before_pic_text
        image_viewer -h "$image_height" -w "$terminal_width" "$rand_pic_file"
        printf "%s" $after_pic_text
    end
end
