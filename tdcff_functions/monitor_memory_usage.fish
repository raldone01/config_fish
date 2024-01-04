#!/bin/fish
function tdc_monitor_memory_usage --description "Monitor memory usage of a process"
  argparse "p/pid=!_validate_int --min 0" "n/timestep=!_validate_int --min 0" -- $argv

  set -l pid $_flag_pid
  set -l timestep $_flag_timestep

  if test $status -ne 0 -o -z "$_flag_pid"
    printf "Usage: tdc_monitor_memory_usage -p <pid> [-n <timestep>]\n"
    return 1
  end

  if test -z "$timestep"
    set timestep 5
  end

  set -l mem_usage
  set -l counter 0

  printf "Monitoring memory usage of process %d. Updates every %d seconds.\n" $pid $timestep

  while true
    set mem_usage (ps -p $pid -o rss=)
    set timestamp (date +"%d/%b/%Y")

    if test $mem_usage -gt 1048576
      set mem_usage (math $mem_usage / 1048576)
      set mem_unit GB
    else if test $mem_usage -gt 1024
      set mem_usage (math $mem_usage / 1024)
      set mem_unit MB
    else
      set mem_unit KB
    end

    printf "[%s][%d] Memory usage of process %d: %.2f %s\n" $timestamp $counter $pid $mem_usage $mem_unit

    sleep $timestep
    set -q counter
    set counter (math $counter + 1)
  end

end

if not string match -q -- "*from sourcing file*" (status)
  tdc_monitor_memory_usage $argv
end
