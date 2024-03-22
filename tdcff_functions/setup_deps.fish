#!/bin/fish
function tdc_setup_deps --description "Installs/Reinstalls the dependencies of tdc."
  if not type -q yay
    echo "yay not installed"
    return 1
  end
  if not type -q rustup
    echo "rustup not installed"
    return 1
  end
  if not type -q cargo
    echo "cargo not installed"
    return 1
  end
  yay -Sy fish rustup keychain figlet boxes kubectl rsync zoxide
  rustup install stable
  cargo install viu exa
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_setup_deps $argv
end
