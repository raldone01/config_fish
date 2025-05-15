#!/bin/fish
function tdc_update --description "Update the system" --argument build_kernels
  set -l fish_binary (command -v fish)
  echo "Updating system packages"
  if type -q pacman
    set -le pacman_options
    if test -z "$build_kernels"
      set -a pacman_options --ignore "linux-*-git" --ignore "linux-*-git-headers" --ignore "linux-*-git-docs" --ignore linux-git --ignore linux-git-headers --ignore linux-git-docs
    end
    if type -q yay && tdc_is_proper_user
      echo "Running yay -Syu"
      yay --sudoloop -Syu --devel $pacman_options
    else
      echo "Running sudo pacman -Syu"
      sudo pacman -Syu $pacman_options
    end
  else if type -q apt-get
    echo "Running apt-get update && apt-get upgrade"
    sudo $fish_binary -c "apt-get update && apt-get upgrade"
  else if type -q dnf
    echo "Running dnf upgrade"
    sudo $fish_binary -c "dnf upgrade"
  else
    echo "Failed to update system packages."
    echo "Unknown system package manager or distribution."
  end
  if type -q rustup && tdc_is_proper_user
    echo "Updating rustup"
    rustup self update
    echo "Updating the rust toolchain"
    rustup update
  end
  # https://stackoverflow.com/a/66049504/4479969
  if type -q cargo && tdc_is_proper_user
    echo "Updating the crates installed with 'cargo install'"
    cargo install $(cargo install --list | grep -E '^[a-z0-9_-]+ v[0-9.]+:$' | cut -f1 -d' ')
  end
  if type -q fisher && tdc_is_proper_user
    echo "Updating the fisher fish plugins"
    fisher update
  end
  if type -q flatpak
    echo "Updating the installed flatpaks"
    flatpak update
  end
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_update $argv
end

alias update tdc_update
