#!/bin/fish
function tdc_btrfs_convert --description "Converts a file/folder to a no data CoW file/folder/subvolume"
  set -lx logging 0

  function __log --argument message
    if test $logging -eq 1
      echo "$message"
    end
  end

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
    if test -z "$value"
      set value $_flag_value
    end
    switch $value
    case true True Yes yes false False No no
      return 0
    end
    return 1
  end

  function __normalize_boolean --argument value
    switch $value
    case true True Yes yes
      echo 1
      return 0
    case false False No no
      echo 0
      return 0
    end
    echo "Invalid boolean value: $value"
    return 1
  end

  function __print_usage
    printf "Usage: tdc_btrfs_convert [OPTIONS] INPUT_PATH\n"
    printf "Converts a file/folder to a no data CoW file/folder/subvolume\n"
    printf "\n"
    printf "Options:\n"
    printf "  --nocow         Disable CoW on the output file\n"
    printf "  --subvol        Convert the folder to a subvolume\n"
    printf "  --delete-backup Delete the backup\n"
    printf "  -h, --help      Display this help and exit\n"
  end

  argparse "subvol=!__validate_boolean" "input_path=" "nocow=!__validate_boolean" "delete-backup" -- $argv
  set -l argparse_status $status

  set -lx input_path "$_flag_input_path"
  set -lx subvol "$_flag_subvol"
  set -l nocow "$_flag_nocow"
  set -lx delete_backup "$_flag_delete_backup"

  __log "Parsed arguments: input_path: $input_path subvol: $subvol nocow: $nocow delete_backup: $delete_backup"
  __log "Remaining arguments: $argv"
  __log "argparse_status: $argparse_status"

  # error print usage
  if test $argparse_status -ne 0
    __print_usage
    return 1
  end

  if test -z "$input_path"
    set input_path $argv[1]
    set -e argv[1]
  end

  __log "input_path: $input_path subvol: $subvol nocow: $nocow delete_backup: $delete_backup"

  if test -z "$input_path"
     or not test -e "$input_path"
    printf "The input path is not valid.\n"
    __print_usage
    return 1
  end

  set -lx unix_time (date +%s)

  # remove trailing slashes
  set -lx input_path (string trim -r -c "/" "$input_path")

  set -lx backup_path (string join "" "$input_path" "_backup")
  set -lx temp_path (string join "" "$input_path" "_temp" "$unix_time")

  # handle nocow flag
  __log "nocow: $nocow"
  if test -z "$nocow"
    set nocow false
    if __read_confirm "Disable CoW"
      set nocow true
    end
  end
  set -l nocow (__normalize_boolean "$nocow")
  if test $status -ne 0
    return 1
  end

  set -l reflink_option "--reflink=auto"
  if test $nocow -eq 1
    set reflink_option "--reflink=never"
  end

  # handle nobackup flag
  function __handle_delete_backup
    if test -z "$delete_backup"
      set delete_backup false
      if __read_confirm "Delete the backup"
        set delete_backup true
      end
    end
    set -l delete_backup (__normalize_boolean "$delete_backup")
    if test $status -ne 0
      return 1
    end

    if test "$delete_backup" -eq 1
      rm -rf "$backup_path"
    end
  end

  # Check if the input_path is a file
  if test -f "$input_path"
    __log "The input path is a file"
    mv "$input_path" "$backup_path"
    touch "$input_path"
    if test $nocow -eq 1
      chattr +C "$input_path"
    end
    cp -p $reflink_option "$backup_path" "$input_path"
    __handle_delete_backup
    return 0
  end

  # Check if the input_path is a folder
  if not test -d "$input_path"
    printf "\"%s\" is not a directory.\n" "$input_path"
    return 1
  end

  __log "The input path is a folder"

  # handle subvol flag
  __log "subvol: $subvol"
  if test -z "$subvol"
    set subvol false
    if __read_confirm "Convert the folder to a subvolume"
      set subvol true
    end
  end
  set -l subvol (__normalize_boolean "$subvol")
  if test $status -ne 0
    return 1
  end

  # Create a temporary folder/subvolume
  if test $subvol -eq 1
    btrfs subvolume create "$temp_path"
  else
    mkdir -p "$temp_path"
  end

  # Copy the attributes of the original folder to the new subvolume
  rsync -ptgo -A -X -d --no-recursive "$input_path/" "$temp_path"

  # Exclude the new folder from CoW
  if test $nocow -eq 1
    chattr -R +C "$temp_path"
  end

  # Copy the contents of the original folder to the new folder
  cp -a $reflink_option "$input_path"/{.,}* "$temp_path/"

  # Move the original folder to the backup location
  mv "$input_path" "$backup_path"

  # Move the new folder to the original folder location
  mv "$temp_path/" "$input_path"

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
#
# sudo rm test_file
# echo "TestFile" > test_file
# tdc_btrfs_convert test_file
# lsattr -a test_file
