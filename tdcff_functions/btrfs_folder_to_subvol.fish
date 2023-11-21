#!/bin/fish
function tdc_btrfs_folder_to_subvol --description "Convert a folder to a subvolume" --argument folder_path
    if test -z "$folder_path"
        printf "Usage: tdc_btrfs_folder_to_subvol /path/to/folder\n"
        return 1
    end

    # remove trailing slashes
    set -l folder_path (string trim -r -c "/" $folder_path)

    set -l backup_path (string join "" "$folder_path" "_backup")
    set -l subvol_path (string join "" "$folder_path" "_volume")

    if not test -d "$folder_path"
        printf "\"%s\" is not a directory.\n" "$folder_path"
        return 1
    end

    # Create a new subvolume
    btrfs subvolume create "$subvol_path"

    # Copy the attributes of the original folder to the new subvolume
    rsync -ptgo -A -X -d --no-recursive "$folder_path/" "$subvol_path"

    # Copy the contents of the original folder to the new subvolume using reflink
    cp --reflink=auto -p -R "$folder_path"/{.,}* "$subvol_path/"

    # Move the original folder to the backup location
    mv "$folder_path" "$backup_path"

    # Move the subvolume to the original folder location
    mv "$subvol_path/" "$folder_path"

    echo "The folder has been converted to a subvolume."
    echo "A backup of the original folder is available at $backup_path"

    # Common directories to exclude from CoW and snapshots
    # /var/cache/
    # /var/log
    # /var/cache/binpkgs
    # /var/db/repos
    # ~/Games
    # ~/.steam/root/steamapps

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

    # Ask user if Cow should be disabled on the new subvolume
    if __read_confirm "Disable CoW on the new subvolume"
        chattr +C "$folder_path"
    end

    # Ask user if backups should be deleted
    if __read_confirm "Delete the backup"
        rm -rf "$backup_path"
    end
end

if not string match -q -- "*from sourcing file*" (status)
    tdc_btrfs_folder_to_subvol $argv
end

# Test stuff
# sudo rm -rf test_folder*
# source /home/main/.config/fish/functions/btrfs_folder_to_subvol.fish
# mkdir test_folder
# touch test_folder/test_file
# touch test_folder/.test_hidden_file
# mkdir test_folder/.oof
# touch test_folder/.oof/.test_hidden_file
#
# tree -a test_folder
#
# btrfs subvol create test_folder_volume
# cp --reflink=auto -R test_folder/{.,}* test_folder_volume/
# mv test_folder test_folder_backup
# mv test_folder_volume/ test_folder
#
# tree -a test_folder
