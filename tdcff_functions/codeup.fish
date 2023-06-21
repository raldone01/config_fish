#!/bin/fish
function tdc_codeup --description "Update visual studio code aur packages if installed."
  set -l packages_to_update
  if type -q code
    set -a packages_to_update "visual-studio-code-bin"
  end
  if type -q code-insiders
    set -a packages_to_update "visual-studio-code-insiders-bin"
  end
  yay -Sy $packages_to_update
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_codeup $argv
end

alias codeup tdc_codeup
