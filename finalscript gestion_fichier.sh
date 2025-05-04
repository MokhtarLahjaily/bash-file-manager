#!/bin/bash

# Function to display the main menu with an animated title
display_main_menu() {
    clear
    echo -e "\e[1;32m"  # Bright Green color
    for ((i=0; i<10; i++)); do
        case $i in
            0) echo "     //   ) )     //   ) )      ___         ____ ";;
            1) echo "    //           //___/ /     //   ) )    // ";;
            2) echo "   //  ____     / __  (      //   / /    //__ ";;
            3) echo "  //    / /    //    ) )    //   / /         ) ) ";;
            4) echo " ((____/ /    //____/ /    ((___/ /    ((___/ / ";;
        esac
        sleep 0.3  # Time to display each line
    done
    echo -e "\e[0m"  # Reset color
    echo -e "### Advanced File Management System ###"
    echo "1. Navigate directories"
    echo "2. File management"
    echo "3. Directory management"
    echo "4. Copy, move, and search files"
    echo "5. Manage file permissions"
    echo "6. Modify timestamps"
    echo "7. Merge directories"
    echo "8. Synchronize files between different destinations"
    echo "9. Create symbolic links"
    echo
    echo -e "\e[1;31m 0.Exit"
    echo -e "\e[0m"
    echo
    echo -n "Enter your choice : "
}

# Function to display error messages
display_error() {
    echo "Error: $1"
    read -p "Press Enter to continue."
}

# Function to display success messages
display_success() {
    echo "Success: $1"
    read -p "Press Enter to continue."
}

# Function to validate file or directory names
validate_name() {
    local name=$1
    if [[ "$name" =~ [^a-zA-Z0-9._-] ]]; then
        display_error "Invalid name. Please use alphanumeric characters, periods, underscores, or dashes."
        return 1
    fi
}

# Function to validate directory existence
validate_directory() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        display_error "Directory '$dir' does not exist."
        return 1
    fi
}



# Function to navigate directories
navigate_directories() {
    while true; do  # Loop to continue navigation until the user chooses to exit
        clear
        echo "Navigate directories"
        echo "Current directory: $(pwd)"
        
        # Show available directories
        echo "Available directories:"
        ls -l | grep "^d" | awk '{print $NF}'

        read -p "Enter the name of a directory , '..' to go up a level, '/' to go to the root, or 'q' to quit: " dir_name

        # Verify if the input is '..' to go up a level
        if [ "$dir_name" = ".." ]; then
            # Go up one level
            cd .. 
            echo "Navigated up one level." && display_success "Current directory: $(pwd)"
        # Verify if the input is '/' to go to the root
        elif [ "$dir_name" = "/" ]; then
            # Go to root level
            cd /
            echo "Navigated to the root." && display_success "Current directory: $(pwd)"
        elif [ "$dir_name" = "q" ]; then
            echo "Exiting navigation."
            return  # Exit the function
        elif [ -d "$dir_name" ]; then
            # Navigate to the specified directory
            loading-icon 60 "Navigating to $dir_name..."
            cd "$dir_name" && display_success "Current directory: $(pwd)" || { echo "Error: Unable to navigate to '$dir_name'."; read -p "Press Enter to continue."; continue; }
            echo "Navigated to: $(pwd)"
        else
            echo "Error: Directory '$dir_name' does not exist ."
            read -p "Press Enter to continue."
            continue  # Continue the loop for another navigation attempt
        fi

        read -p "Press Enter to continue navigating or 'q' to quit: " choice
        if [ "$choice" = "q" ]; then
            echo "Exiting navigation."
            break  # Exit the loop and function
        fi
    done
}



# Function to manage files
manage_files() {
    clear
    echo "File management"
    echo
    echo "1. Create a file"
    echo "2. Delete a file"
    echo "3. Rename a file"
    echo "4. Show existing files"
    echo
    echo -e "5. Return to the main menu"
    echo
    echo -n "Enter your choice : "
    read choice
    case $choice in
        1) echo -n "Enter the name of the file to create : "; read filename
           if validate_name "$filename" && [ ! -e "$filename" ]; then
               touch "$filename" && display_success "File created: $filename"
           elif [ -e "$filename" ]; then
               display_error "File '$filename' already exists."
           fi
           ;;
       2) echo -n "Enter the name of the file to delete : "; read filename
           if validate_name "$filename" && [ -e "$filename" ]; then
               rm -rf "$filename" && display_success "File deleted: $filename"
           else
               display_error "File '$filename' does not exist."
           fi
           ;;
        3) echo -n "Enter the old name of the file : "; read oldname
           if [ -e "$oldname" ]; then
               echo -n "Enter the new name : "; read newname
               if validate_name "$newname" && [ ! -e "$newname" ]; then
                   mv "$oldname" "$newname" && display_success "File renamed: $oldname -> $newname"
               elif [ -e "$newname" ]; then
                   display_error "File '$newname' already exists."
               fi
           else
               display_error "File '$oldname' does not exist."
           fi
           ;;
        4) ls -l | grep "^-" && read -p "Press Enter to continue.";;  # List regular files
        5) return;;
        *) display_error "Invalid choice. Please select a valid option.";;
    esac
    manage_files
}

# Function to manage directories
manage_directories() {
    clear
    echo "Directory management"
    echo
    echo "1. Create a directory"
    echo "2. Delete a directory"
    echo "3. Rename a directory"
    echo "4. Show existing directories"
    echo "5. Return to the main menu"
    echo
    echo -n "Enter your choice : "
    read choice
    case $choice in
        1) echo -n "Enter the name of the directory to create : "; read dirname
           if [ -z "$dirname" ]; then
               display_error "Directory name cannot be empty."
           else
               mkdir "$dirname" && display_success "Directory created: $dirname"
           fi
           ;;
        2) echo -n "Enter the name of the directory to delete : "; read dirname
           if [ -z "$dirname" ]; then
               display_error "Directory name cannot be empty."
           elif validate_directory "$dirname"; then
               rm -rf "$dirname" && display_success "Directory deleted: $dirname"
           fi
           ;;
        3) echo -n "Enter the old name of the directory : "; read oldname
           if [ -z "$oldname" ]; then
               display_error "Old directory name cannot be empty."
           elif validate_directory "$oldname"; then
               echo -n "Enter the new name : "; read newname
               if [ -z "$newname" ]; then
                   display_error "New directory name cannot be empty."
               elif validate_directory "$newname"; then
                   display_error "Directory '$newname' already exists."
               else
                   mv "$oldname" "$newname" && display_success "Directory renamed: $oldname -> $newname"
               fi
           fi
           ;;
        4) ls -l | grep "^d" && read -p "Press Enter to continue.";;
        5) return;;
        *) display_error "Invalid choice. Please select a valid option.";;
    esac
    manage_directories
}

# Function to copy a file
copy_file() {
    echo -n "Enter the name of the file to copy : "; read filename
    if validate_name "$filename" && [ -e "$filename" ]; then
        echo -n "Enter the destination directory : "; read destination
        if validate_directory "$destination" ; then
            echo -n "Do you want to rename the file? (y/n) : "; read rename_choice
            if [ "$rename_choice" == "y" ]; then
                echo -n "Enter the new name for the file : "; read new_filename
                if validate_name "$new_filename" && [ ! -e "$destination/$new_filename" ]; then
                    cp "$filename" "$destination/$new_filename" && display_success "File copied to $destination with new name: $new_filename"
                else
                    display_error "Invalid new file name or file already exists in the destination directory."
                fi
            else
                loading-icon 60 "Copying file '$filename' to '$destination'..."
                cp "$filename" "$destination" && display_success "File copied to $destination"
            fi
        fi
    else
        display_error "File '$filename' does not exist."
    fi
}

# Function to move a file
move_file() {
    echo -n "Enter the name of the file to move : "; read filename
    if validate_name "$filename" && [ -e "$filename" ]; then
        echo -n "Enter the destination directory : "; read destination
        if validate_directory "$destination" ; then
            loading-icon 60 "Moving file '$filename' to '$destination'..."
            mv "$filename" "$destination" && display_success "File moved to $destination"
        fi
    else
        display_error "File '$filename' does not exist."
    fi
}

# Function to search for a file
search_file() {
    echo -n "Enter the name or part of the name of the file to search for : "; read search_name
    if validate_name "$search_name"; then
        echo "Searching for files matching '$search_name'..."
        loading-icon 60 "Searching for files matching '$search_name'..."
        found_files=$(find . -type f -iname "*${search_name}*")
        if [ -z "$found_files" ]; then
            echo "No files found matching '$search_name'."
        else
            echo "Files found:"
            echo "$found_files"
        fi
    fi
}

# Modify the copy_move_search_files function to use these new functions

copy_move_search_files() {
    clear
    echo "Copy, move, and search files"
    echo
    echo "1. Copy a file"
    echo "2. Move a file"
    echo "3. Search for a file"
    echo "4. Return to the main menu"
    echo
    echo -n "Enter your choice : "
    read choice
    case $choice in
        1) copy_file;;
        2) move_file;;
        3) search_file;;
        4) return;;
        *) display_error "Invalid choice. Please select a valid option.";;
    esac
    copy_move_search_files
}

# Function to manage file permissions
manage_file_permissions() {
    clear
    echo "Manage file permissions"
    echo
    echo "1. Change file permissions"
    echo "2. Show file permissions"
    echo "3. Return to the main menu"
    echo
    echo -n "Enter your choice : "
    read choice
    case $choice in
        1) echo -n "Enter the name of the file : "; read filename
           if validate_name "$filename" && [ -e "$filename" ]; then
               echo -n "Enter the new permissions (e.g., 755) : "; read permissions
               chmod "$permissions" "$filename" && display_success "Permissions changed for $filename"
           else
               display_error "File '$filename' does not exist."
           fi
           ;;
       2) ls -l && read -p "Press Enter to continue.";;
        3) return;;
        *) display_error "Invalid choice. Please select a valid option.";;
    esac
    manage_file_permissions
}

# Function to modify timestamps
modify_timestamps() {
    clear
    echo "Modify timestamps"
    echo
    echo "1. Change file access time"
    echo "2. Change file modification time"
    echo "3. Return to the main menu"
    echo
    echo -n "Enter your choice : "
    read choice
    case $choice in
        1) echo -n "Enter the name of the file : "; read filename
           if validate_name "$filename" && [ -e "$filename" ]; then
               current_date=$(date +%Y-%m-%d)
               read -p "Enter the new access time (YYYY-MM-DD HH:MM:SS) : " access_time
               if [[ -z $access_time ]]; then
                   display_error "Access time cannot be empty."
               elif ! date -d "$access_time" &>/dev/null; then
                   display_error "Invalid access time format. Please use YYYY-MM-DD HH:MM:SS."
               elif [[ "$access_time" > "$current_date 23:59:59" ]]; then
                   display_error "Access time cannot be after now's date."
               else
                   touch -a -d "$access_time" "$filename" && display_success "Access time changed for $filename"
               fi
           else
               display_error "File '$filename' does not exist."
           fi
           ;;
       2) echo -n "Enter the name of the file : "; read filename
           if validate_name "$filename" && [ -e "$filename" ]; then
               current_date=$(date +%Y-%m-%d)
               read -p "Enter the new modification time (YYYY-MM-DD HH:MM:SS) : " mod_time
               if [[ -z $mod_time ]]; then
                   display_error "Modification time cannot be empty."
               elif ! date -d "$mod_time" &>/dev/null; then
                   display_error "Invalid modification time format. Please use YYYY-MM-DD HH:MM:SS."
               elif [[ "$mod_time" > "$current_date 23:59:59" ]]; then
                   display_error "Modification time cannot be after today's date."
               else
                   touch -m -d "$mod_time" "$filename" && display_success "Modification time changed for $filename"
               fi
           else
               display_error "File '$filename' does not exist."
           fi
           ;;
        3) return;;
        *) display_error "Invalid choice. Please select a valid option.";;
    esac
    modify_timestamps
}

# Function to merge directories
merge_directories() {
    clear
    echo
    echo "Merge directories"
    echo
    read -p "Enter the name of the first directory: " dir1
    if validate_directory "$dir1"; then
        read -p "Enter the name of the second directory: " dir2
        if validate_directory "$dir2"; then
            loading-icon 60 "Merging directories '$dir1' and '$dir2' ..."
            rsync -avh --ignore-existing "$dir1/" "$dir2" && display_success "Directories merged: $dir1 into $dir2"
        fi
    fi
    
}

synchronize_files() {
    clear
    echo
    echo "Synchronize files between different destinations"
    echo
    read -p "Enter the name of the first directory: " dir1
    if validate_directory "$dir1"; then
        read -p "Enter the name of the second directory: " dir2
        if validate_directory "$dir2"; then
            loading-icon 60 "Synchronizing files from '$dir1' to '$dir2'..."
            rsync -avh --delete "$dir1/" "$dir2" && display_success "Files synchronized from $dir1 to $dir2"
        fi
    fi
    read -p "Press Enter to continue."
}


# Function to create symbolic links
create_symbolic_link() {
    clear
    echo
    echo "Create symbolic link"
    echo
    echo -n "Enter the path of the target file or directory : "; read target
    echo -n "Enter the name of the symbolic link : "; read link_name
    ln -s "$target" "$link_name" && display_success "Symbolic link created: $link_name -> $target"
    
}

function loading-icon() {
local load_interval="${1}"
local loading_message="${2}"
local elapsed=0
local loading_animation=( '—' "\\" '|' '/' )

echo -n "${loading_message} "

# This part is to make the cursor not blink
# on top of the animation while it lasts
tput civis
trap "tput cnorm" EXIT

# Calculate the end time
end_time=$((SECONDS + 2))

while [ "${load_interval}" -ne "${elapsed}" ]; do
    # Exit loop if current time exceeds end time
    if [ $SECONDS -ge $end_time ]; then
        break
    fi

    for frame in "${loading_animation[@]}" ; do
        printf "%s\b" "${frame}"
        sleep 0.25
    done
    elapsed=$(( elapsed + 1 ))
done
}

# Main function to run the script
main() {
    while true; do
        display_main_menu
        read choice
        case $choice in
            1) navigate_directories;;
            2) manage_files;;
            3) manage_directories;;
            4) copy_move_search_files;;
            5) manage_file_permissions;;
            6) modify_timestamps;;
            7) merge_directories;;
            8) synchronize_files;;
            9) create_symbolic_link;;
            0) echo "Exiting the program."; exit;;
            *) display_error "Invalid choice. Please select a valid option.";;
        esac
    done
}

loading-icon() {
    local duration=$1
    local message=$2
    echo -n "$message"
    for ((i=0; i<$duration/10; i++)); do
        echo -n "."
        sleep 0.1
    done
    echo
}


# Run the main function
main
