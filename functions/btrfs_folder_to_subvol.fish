#!/usr/bin/fish

function folder_to_subvolume --description "Convert a folder to a subvolume with CoW disabled" --argument folder_path
    if test -z "$folder_path"
        printf "Usage: folder_to_subvolume /path/to/folder\n"
        return 1
    end

    set backup_path (string join "" "$folder_path" "_backup")
    set subvol_path (string join "" "$folder_path" "_subvol")

    # Create snapshot of folder as a subvolume
    sudo btrfs subvolume snapshot "$folder_path" "$subvol_path"

    # Disable CoW on the new subvolume
    sudo chattr +C "$subvol_path"

    # Move the original folder to backup location
    sudo mv "$folder_path" "$backup_path"

    # Move the subvolume to the original folder location
    sudo mv "$subvol_path" "$folder_path"

    echo "The folder has been converted to a subvolume with CoW disabled."
    echo "A backup of the original folder is available at $backup_path"
end

if test (count $argv) -eq 1
    folder_to_subvolume $argv[1]
else
    printf "Usage: folder_to_subvolume /path/to/folder\n"
end
