#!/bin/fish
function tdc_update --description "Update the system" --argument build_kernels "Build git kernels"
    echo "Updating system packages..."
    if grep -qi "Arch Linux" /etc/os-release
        set -le pacman_options
        if test -z "$build_kernels"
            set -a pacman_options --ignore "linux-*-git" --ignore "linux-*-git-headers" --ignore "linux-*-git-docs" --ignore linux-git --ignore linux-git-headers --ignore linux-git-docs
        end
        if type -q yay
            yay --sudoloop -Syu --devel $pacman_options
        else
            sudo pacman -Syu $pacman_options
        end
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

if not string match -q -- "*from sourcing file*" (status)
    tdc_update $argv
end

alias update tdc_update
