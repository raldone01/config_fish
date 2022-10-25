# Fish config

## fish_greeting

![Fish Greeting](fish_greeting.png)

Image: https://www.pexels.com/photo/close-up-portrait-of-lion-247502/

Font: Jetbrains Nerd Font Mono

## Tweaked Commands
* `fish_greeting` - See heading above.
* `calm` - Displays a single random image from the configured folders.
* `pic_not_nice` - Deletes the last image displayed by `fish_greeting` or `calm`.
* `yay` - Includes the `--sudoloop` option by default.
* `update` - Custom arch update script.
  * Updates the system with `yay`.
  * Updates rust with `rustup`.
  * Updates programs installed with `cargo install`.
  * Updates fisher.
* `ls` - Aliased to `exa`.
* `la` - Aliased to `exa -a`.
* `tree` - Aliased to `exa --tree`.
* `fish_prompt` - Changed to [tide](https://github.com/IlanCosman/tide).

## Setup

* Configure a nerd font for your terminal emulator
* Install the dependencies you need. See `install_arch.fish` file.
* `mv ~/.config/fish ~/.config/fish.bak`
* `git -C ~/.config clone https://github.com/raldone01/config_fish.git fish`
* `cd ~/.config/fish`
* `cp machine-config.fish.example machine-config.fish`
* `$EDITOR machine-config.fish`
* `fish`
* `update`
