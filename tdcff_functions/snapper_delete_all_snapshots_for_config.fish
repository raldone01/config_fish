#!/bin/fish
function tdc_snapper_delete_all_snapshots_for_config --description "Deletes all snapshots for the selected config." --argument config
  if test -z "$config"
    printf "Usage: tdc_snapper_delete_all_snapshots_for_config <config_name>\n"
    return 1
  end

  set snapshot_numbers "$(sudo snapper --no-headers --csvout --config "$config" list --columns number | tail -n +2)"

  for i in $snapshot_numbers;
    sudo snapper -c "$config" delete $i;
  end
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_snapper_delete_all_snapshots_for_config $argv
end
