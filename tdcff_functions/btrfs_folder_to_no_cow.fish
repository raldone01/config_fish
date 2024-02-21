#!/bin/fish
function tdc_btrfs_convert --description "Converts a file/folder to a no data CoW file/folder/subvolume"
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

  function __validate_boolean --argument value
    switch $value
    case true True Yes yes false False No no
      return 0
    end
    return 1
  end

  function __normalize_boolean --argument value
    switch $value
    case true True Yes yes
      return 0
    case false False No no
      return 1
    end
    return $value
  end

  function __print_usage
    printf "Usage: tdc_btrfs_convert [OPTIONS] INPUT_PATH\n"
    printf "Converts a file/folder to a no data CoW file/folder/subvolume\n"
    printf "\n"
    printf "Options:\n"
    printf "  --nocow         Disable CoW on the output file\n"
    printf "  --delete-backup Delete the backup\n"
    printf "  -h, --help      Display this help and exit\n"
  end

  # to_type can be file, folder or subvolume
  argparse "to_type=" "input_path=" "nocow=!__validate_boolean" "delete-backup" -- $argv
  # error print usage
  if test $status -ne 0
    __print_usage
    return 1
  end

  set -l input_path = $_flag_input_path
  set -l to_type = $_flag_to_type
  set -l nocow = $_flag_nocow
  set -l delete_backup = $_flag_delete_backup

  if test -z "$input_path"
    set -l input_path $argv[1]
    set -e $argv[1]
  end

  if test -z "$input_path" or test -e "$input_path"
    printf "The input path is not valid.\n"
    __print_usage
    return 1
  end

  set -l unix_time (date +%s)

  # remove trailing slashes
  set -l input_path (string trim -r -c "/" $input_path)

  set -l backup_path (string join "" "$folder_path" "_backup")
  set -l temp_path (string join "" "$folder_path" "_temp" "$unix_time")

  # handle nocow flag
  if test -z "$nocow"
    set -l nocow false
    if __read_confirm "Disable CoW on the new subvolume"
      set -l nocow true
    end
  end
  set -l nocow (__normalize_boolean $nocow)

  set -l reflink_option "--reflink=auto"
  if $nocow
    set reflink_option "--reflink=never"
  end

  # handle nobackup flag
  function __handle_delete_backup
    set -l delete_backup (__normalize_boolean $delete_backup)
    if $delete_backup
      if __read_confirm "Delete the backup"
        set -l delete_backup true
      else
        set -l delete_backup false
      end
    end
    if $delete_backup
      rm -rf "$backup_path"
    end
  end

  # Check if the input_path is a file
  if test -f "$input_path"
    mv "$input_path" "$input_path"_backup
    touch "$input_path"
    if $nocow
      chattr +C "$input_path"
    end
    cp -p $reflink_option "$input_path"_backup "$input_path"
    __handle_delete_backup
    return 0
  end

  # Check if the input_path is a folder
  if not test -d "$input_path"
    printf "\"%s\" is not a directory.\n" "$input_path"
    return 1
  end

  # Create a temporary folder/subvolume
  if test $to_type = "subvolume"
    btrfs subvolume create "$temp_path"
  else
    mkdir -p "$temp_path"
  end

  # Copy the attributes of the original folder to the new subvolume
  rsync -ptgo -A -X -d --no-recursive "$input_path/" "$temp_path"

  # Exclude the new folder from CoW
  if $nocow
    chattr -R +C "$temp_path"
  end

  # Copy the contents of the original folder to the new folder
  cp -a $reflink_option "$folder_path"/{.,}* "$temp_path/"

  # Move the original folder to the backup location
  mv "$folder_path" "$backup_path"

  # Move the new folder to the original folder location
  mv "$temp_path/" "$folder_path"

  echo "The folder has been converted."
  echo "A backup of the original folder is available at $backup_path"

  __handle_delete_backup
end

if not string match -q -- "*from sourcing file*" (status)
  tdc_btrfs_convert $argv
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
# tdc_btrfs_convert test_folder
#
# tree -a test_folder
# lsattr test_folder -a
# tree -a test_folder_backup
