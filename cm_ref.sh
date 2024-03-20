#!/bin/bash

# Define the file path for the commands text file
commands_file="bash_commands.txt"

# Function to initialize the bash_commands array
initialize_array() {
    declare -A bash_commands
}

# Function to load commands from the text file into the dictionary
load_commands() {
    while IFS='|' read -r command usage examples; do
        bash_commands["$command"]="Usage: $usage\nExamples:\n$examples"
    done < "$commands_file"
}

# Function to save commands from the dictionary to the text file
save_commands() {
    for command in "${!bash_commands[@]}"; do
        echo -e "$command|${bash_commands[$command]//\n/\\n}" >> "$commands_file"
    done
}

# Function to extract usage from man page of a command
extract_usage() {
    local command="$1"
    local usage=$(man "$command" | grep -E 'SYNOPSIS|USAGE' | grep -v '^[[:space:]]*$' | head -n 1)
    local examples=$(man "$command" | grep -A 1 '^EXAMPLES' | tail -n 1)
    
    if [[ -n "$usage" ]]; then
        if [[ -n "$examples" ]]; then
            bash_commands["$command"]="Usage: $usage\nExamples:\n$examples"
        else
            bash_commands["$command"]="Usage: $usage\nNo examples found."
        fi
        echo "Information for '$command' extracted and updated in the dictionary."
    else
        echo "Information for '$command' not found in the man page."
    fi
}

# Function to prompt the user for a command
prompt_user() {
    echo "-----------------------------------------------------------"
    read -p "Enter the command you want to learn about (or type 'exit' to quit): " command
    if [[ "$command" == "exit" ]]; then
        echo "Exiting the program."
        exit 0
    elif [[ -n "${bash_commands[$command]}" ]]; then
        echo -e "${bash_commands[$command]}"
    else
        echo "Information for '$command' not found in the dictionary."
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

    # Save the updated dictionary to the text file
    save_commands
}

# Run the main function
main
