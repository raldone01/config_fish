#!/bin/fish
function tdc_hello_world --description "Print hello world"
  echo "Hello world"
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_hello_world $argv
end
