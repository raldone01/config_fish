#!/bin/fish

yay -Syu fish rustup keychain figlet boxes kubectl --needed
rustup install stable
cargo install viu exa
