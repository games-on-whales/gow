#!/bin/bash
set -e

# Define the output file
output_file="website/public/apps.toml"

# Clear the output file if it exists
> "$output_file"

# Iterate over each subfolder in apps/
for dir in apps/*; do
    # Check if the directory exists and is a directory
    if [ -d "$dir" ]; then
        # Define the config file path
        config_file="$dir/assets/wolf.config.toml"

        # Check if the config file exists
        if [ -f "$config_file" ]; then
            # Append the contents of the config file to the output file
            cat "$config_file" >> "$output_file"
            echo "" >> "$output_file"  # Add a newline for separation between files
        else
            echo "Warning: $config_file does not exist."
        fi
    fi
done

echo "Concatenation complete. Output written to $output_file."