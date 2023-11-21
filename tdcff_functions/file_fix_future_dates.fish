#!/bin/fish

# TODO: Enhance set to current time and match to the timestamp not just the date

function tdc_file_fix_future_dates --description "Fixes file dates in a folder for files with future timestamps." --argument folder

    # Check for proper usage
    set -lx dry_run 0
    if test "$argv[1]" = "--dry-run"
        set dry_run 1
        echo "Dry run enabled!"
        set -e argv[1] # remove the first argument
    end

    # Ensure that a folder is provided
    if test (count $argv) -lt 1
        echo "Usage: tdc_file_fix_future_dates [--dry-run] <folder>"
        return 1
    end

    set -l folder $argv[1]

    # Check if the provided path is a directory
    if not test -d "$folder"
        echo "Error: '$folder' is not a directory."
        return 1
    end

    function __fix_dates --argument file
        if test $dry_run -eq 1
            echo "Would fix: $file"
        else
            echo "Fixing: $file"
            set -l yesterday (date -d "yesterday" +"%Y%m%d")
            set -l time "1200"
            set -l datetime "$yesterday$time"
            touch -t $datetime -am "$file"
        end
    end

    #FIX LOCAL VAR LEAK!!!!

    set -lx fix_dates_function (functions __fix_dates | string split0)

    # Find files with a date in the future and process them
    find "$folder" -newermt (date +%Y-%m-%d) -exec fish -c 'eval $fix_dates_function; __fix_dates "$argv[1]"' {} \;

    if test $dry_run -eq 1
        echo "Dry run completed."
    else
        echo "File dates fixed in: $folder"
    end
end

# Execute the function if not sourced
if not string match -q -- "*from sourcing file*" (status)
    tdc_file_fix_future_dates $argv
end
