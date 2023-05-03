#!/bin/fish

yay -Syu fish rustup keychain figlet boxes kubectl rsync --needed
rustup install stable
cargo install viu exa
