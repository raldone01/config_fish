#!/bin/fish
function tdc_btrfs_folder_to_no_cow --description "Convert a folder to a no data cow folder" --argument folder_path
  function __read_confirm --argument prompt
    while true
      read -l -P "$prompt? [y/N]" confirm

      switch $confirm
      case Y y
        return 0
      case '' N n
        return 1
      end
    end
  end

  if test -z "$folder_path"
    printf "Usage: tdc_btrfs_folder_to_no_cow /path/to/folder\n"
    return 1
  end

  # remove trailing slashes
  set -lx __folder_path (string trim -r -c "/" $folder_path)
  set -e folder_path

  set -l backup_path (string join "" "$__folder_path" "_backup")
  set -lx __new_folder_path (string join "" "$__folder_path" "_no_cow")

  if not test -d "$__folder_path"
    printf "\"%s\" is not a directory.\n" "$__folder_path"
    return 1
  end

  # Create the new folder
  mkdir -p "$__new_folder_path"

  # Common directories to exclude from CoW
  # databases
  # /var/cache/
  # /var/log
  # /var/cache/binpkgs
  # /var/db/repos
  # ~/Games
  # ~/.steam/root/steamapps

  # Exclude the new folder from CoW
  chattr +C "$__new_folder_path"

  set -lx __working_directory (pwd)

  function __touch_no_cow --argument file --argument is_folder
    cd "$__working_directory"
    set -l original_file_path "$__folder_path/$file"
    set -l new_file_path "$__new_folder_path/$file"

    # echo "Working directory: $__working_directory"
    # echo "File: $file"
    # echo "New file path: $new_file_path"

    if test "$is_folder" = "1"
      mkdir -p "$new_file_path"
    else
      touch "$new_file_path"
    end
    chattr +C "$new_file_path"

    # function __copy_x_attributes --argument source_file destination_file
    #   # Read extended attributes from source file
    #   getfattr -d -m "-" $source_file | while read -l attribute
    #       # Check if attribute contains an '='
    #       if string match -q "*=*" $attribute
    #           # Split the attribute into key and value
    #           set key (echo $attribute | cut -d'=' -f1)
    #           set value (echo $attribute | cut -d'=' -f2-)

    #           # Set the attribute to the destination file
    #           echo "setfattr -n $key -v $value $destination_file"
    #           #setfattr -n $key -v $value $destination_file
    #         end
    #     end
    # end
    # __copy_x_attributes "$original_file_path" "$new_file_path"
  end

  # Capture the touch no cow function
  set -lx __touch_no_cow_function (functions __touch_no_cow | string split0)

  # Find all folders
  cd "$__folder_path"
  find -type d -exec fish -c 'eval $__touch_no_cow_function; __touch_no_cow "$argv[1]" 1' {} \;
  # Find all files
  find -type f -exec fish -c 'eval $__touch_no_cow_function; __touch_no_cow "$argv[1]" 0' {} \;
  cd "$__working_directory"

  # Copy all attributes and the content of the original files to the new files
  # Don't copy extended attributes
  rsync -ptgo -A -d --no-recursive "$__folder_path"/{.,}* "$__new_folder_path/"

  # Move the original folder to the backup location
  mv "$__folder_path" "$backup_path"

  # Move the new folder to the original folder location
  mv "$__new_folder_path/" "$__folder_path"

  echo "The folder has been converted to a no cow folder."
  echo "A backup of the original folder is available at $backup_path"

  # Ask user if backups should be deleted
  if __read_confirm "Delete the backup"
    rm -rf "$backup_path"
  end
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_btrfs_folder_to_no_cow $argv
end

# Test stuff
# sudo rm -rf test_folder*
# source /home/main/.config/fish/tdcff_functions/btrfs_folder_to_no_cow.fish
# mkdir test_folder
# echo test_msg > test_folder/test_file
# touch test_folder/.test_hidden_file
# mkdir test_folder/.oof
# touch test_folder/.oof/.test_hidden_file
#
# tree -a test_folder
#
# tdc_btrfs_folder_to_no_cow test_folder
#
# tree -a test_folder
# lsattr test_folder -a
# tree -a test_folder_backup
