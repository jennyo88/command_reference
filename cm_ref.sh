#!/bin/bash

# Define the file path for the commands text file
commands_file="bash_commands.txt"

# Function to load commands from the text file into the dictionary
load_commands() {
    while IFS='|' read -r command usage; do
        bash_commands["$command"]="$usage"
    done < "$commands_file"
}

# Function to save commands from the dictionary to the text file
save_commands() {
    for command in "${!bash_commands[@]}"; do
        echo "$command|${bash_commands[$command]}" >> "$commands_file"
    done
}

# Function to extract usage from man page of a command
extract_usage() {
    local command="$1"
    local usage=$(man "$command" | grep -E 'SYNOPSIS|USAGE' | grep -v '^[[:space:]]*$' | head -n 1)
    if [[ -n "$usage" ]]; then
        bash_commands["$command"]="$usage"
        echo "Usage for '$command' extracted and updated in the dictionary."
    else
        echo "Usage for '$command' not found in the man page."
    fi
}

# Function to prompt the user for a command
prompt_user() {
    read -p "Enter the command you want to learn about (or type 'exit' to quit): " command
    if [[ "$command" == "exit" ]]; then
        echo "Exiting the program."
        exit 0
    elif [[ -n "${bash_commands[$command]}" ]]; then
        echo "Command: $command"
        echo "Usage: ${bash_commands[$command]}"
    else
        echo "Command '$command' not found in the dictionary."
        extract_usage "$command"
    fi
}

# Define the associative array (dictionary)
declare -A bash_commands

# Load commands from the text file into the dictionary
load_commands

# Keep prompting the user until they choose to exit
while true; do
    prompt_user
done

# Save the updated dictionary to the text file
save_commands
