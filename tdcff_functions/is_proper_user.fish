#!/bin/fish
function tdc_is_proper_user --description "Returns 0 if the user is a proper user"
  set -l real_home (getent passwd $USER | cut -d: -f6)
  test "$HOME" = "$real_home"
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_is_proper_user $argv
end
