#!/bin/fish
function tdc_restore_tide_config --description "Sets the tide config to the best config!"
  tide configure --auto --style=Rainbow --prompt_colors='True color' --show_time='24-hour format' --rainbow_prompt_separators=Angled --powerline_prompt_heads=Sharp --powerline_prompt_tails=Flat --powerline_prompt_style='Two lines, character' --prompt_connection=Disconnected --powerline_right_prompt_frame=No --prompt_spacing=Compact --icons='Few icons' --transient=No

  # https://github.com/IlanCosman/tide/wiki/Configuration
  set --universal tide_left_prompt_items pwd git newline character
  set --universal tide_right_prompt_items status cmd_duration context jobs direnv node python rustc java php pulumi ruby go gcloud kubectl distrobox toolbox terraform aws nix_shell crystal elixir zig
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_btrfs_convert $argv
end
