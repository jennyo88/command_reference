#!/bin/bash

# Define the file path for the commands text file
commands_file="bash_commands.txt"

# Function to initialize the bash_commands array
initialize_array() {
    declare -A bash_commands
}

# Function to load commands from the text file into the dictionary
load_commands() {
    while IFS='|' read -r command usage; do
        bash_commands["$command"]="$usage"
    done < "$commands_file"
}

# Function to save commands from the dictionary to the text file
save_commands() {
    > "$commands_file" # Clear the file before writing
    for command in "${!bash_commands[@]}"; do
        echo "$command|${bash_commands[$command]}" >> "$commands_file"
    done
}

# Function to extract usage from man page of a command
extract_usage() {
    local command="$1"
    if [[ -n "${bash_commands[$command]}" ]]; then
        echo "Usage for '$command' found in the dictionary."
        echo "${bash_commands[$command]}"
    else
        local usage=$(man "$command" | head -n 10)
        if [[ -n "$usage" ]]; then
            bash_commands["$command"]="$usage"
            echo "Usage for '$command' extracted and updated in the dictionary."
            echo "$usage"
        else
            echo "Unable to extract usage for '$command' from the man page."
        fi
    fi
}

# Function to prompt the user for a command
prompt_user() {
    echo "-----------------------------------------------------------"
    read -p "Enter the command you want to learn about (or type 'exit' to quit): " command
    if [[ "$command" == "exit" ]]; then
        echo "Exiting the program."
        save_commands
        exit 0
    elif [[ -n "${bash_commands[$command]}" ]]; then
        echo "Command: $command"
        echo "Usage: ${bash_commands[$command]}"
    else
        echo "Command '$command' not found in the dictionary."
        extract_usage "$command"
    fi
    echo "-----------------------------------------------------------"
}

# Main function to control the flow of the script
main() {
    initialize_array
    load_commands

    # Keep prompting the user until they choose to exit
    while true; do
        prompt_user
    done
}

# Run the main function
main
