#!/bin/fish
function tdc_private_ctrl --description "Control the fish private mode"
  argparse t/toggle on off -- $argv

  function __output_private_mode -S
    if test -n "$fish_private_mode"
      echo "Private mode is on"
    else
      echo "Private mode is off"
    end
  end

  set -l toggle $_flag_toggle
  set -l on $_flag_on
  set -l off $_flag_off

  # if no option is set, just output the current state
  if test -z "$toggle" -a -z "$on" -a -z "$off"
    __output_private_mode
    return 0
  end

  set -l count 0
  if test -n "$toggle"
    set count (math $count + 1)
  end
  if test -n "$on"
    set count (math $count + 1)
  end
  if test -n "$off"
    set count (math $count + 1)
  end

  if test "$count" -gt 1
    echo "Only one option can be set"
    __output_private_mode
    return 1
  end

  # toggle private mode
  if test -n "$toggle"
    if test -n "$fish_private_mode"
      set -e fish_private_mode
    else
      set -g fish_private_mode 1
    end
  end

  # enable private mode
  if test -n "$on"
    set -g fish_private_mode 1
  end

  # disable private mode
  if test -n "$off"
    set -e fish_private_mode
  end

  __output_private_mode
  return 0
end

if not string match -q -- "*from sourcing file*" (status)
  echo "This file must be sourced, not executed"
  return 1
end
