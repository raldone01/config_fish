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

  # Check if the folder is a file
  if test -f "$folder_path"
    mv "$folder_path" "$folder_path"_backup
    touch "$folder_path"
    chattr +C "$folder_path"
    cp -p --reflink=never "$folder_path"_backup "$folder_path"
    # Ask user if backups should be deleted
    if __read_confirm "Delete the backup"
      rm -rf "$folder_path"_backup
    end
  end

  # remove trailing slashes
  set -l folder_path (string trim -r -c "/" $folder_path)

  set -l backup_path (string join "" "$folder_path" "_backup")
  set -l new_folder_path (string join "" "$folder_path" "_no_cow")

  if not test -d "$folder_path"
    printf "\"%s\" is not a directory.\n" "$folder_path"
    return 1
  end

  # Create the new folder
  mkdir -p "$new_folder_path"

  # Copy the attributes of the original folder to the new subvolume
  rsync -ptgo -A -X -d --no-recursive "$folder_path/" "$new_folder_path"

  # Common directories to exclude from CoW
  # databases
  # /var/cache/
  # /var/log
  # /var/cache/binpkgs
  # /var/db/repos
  # ~/Games
  # ~/.steam/root/steamapps
  # ~/.local/share/Steam/steamapps/
  # ~/.local/share/baloo/

  # Exclude the new folder from CoW
  chattr -R +C "$new_folder_path"

  # Copy the contents of the original folder to the new folder
  cp -a --reflink=never "$folder_path"/{.,}* "$new_folder_path/"

  # Move the original folder to the backup location
  mv "$folder_path" "$backup_path"

  # Move the new folder to the original folder location
  mv "$new_folder_path/" "$folder_path"

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
