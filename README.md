# The definitive configuration for Fish - tdcff

## fish_greeting

![Fish Greeting](fish_greeting.png)

Image: https://www.pexels.com/photo/close-up-portrait-of-lion-247502/

Font: Jetbrains Nerd Font Mono

## Tweaked Commands
* `fish_greeting` - See image above.
* `calm` - Displays a single random image from the configured folders.
  Skipped if no folders are configured or no images are found.
* `pic_not_nice` - Deletes the last image displayed by `fish_greeting` or `calm`.
* `yay` - Includes the `--sudoloop` option by default.
* `update` - Custom arch update script.
  * Updates the system with `yay`.
  * Updates rust with `rustup`.
  * Updates programs installed with `cargo install`.
  * Updates fisher.
* `codeup` - Updates VsCode/VsCodeInsiders on Arch.
* `ls` - Aliased to `eza`.
* `la` - Aliased to `eza -a`.
* `tree` - Aliased to `eza --tree`.
* `fish_prompt` - Changed to [tide](https://github.com/IlanCosman/tide).
## Prefixed Commands
* `tdc_btrfs_folder_to_subvol` - Converts a folder to a btrfs subvolume.
* `tdc_monitor_memory_usage` - Monitors memory usage of a process given its pid.
* `tdc_setup_deps` - Installs/Reinstalls dependencies for tdcff.

## Setup

* Configure a nerd font for your terminal emulator
* Install the dependencies tdc needs. See `tdcff_functions/setup_deps.fish` file.
* `mv ~/.config/fish ~/.config/fish.bak`
* `git -C ~/.config clone https://github.com/raldone01/config_fish.git fish`
* `cd ~/.config/fish`
* `cp machine-config.fish.example machine-config.fish`
* `$EDITOR machine-config.fish`
* `fish`
* `update`
