#!/bin/bash
# Script to copy 'chat.db' to current directory

# Define source file
src_file="$HOME/Library/Messages/chat.db"

# Check if source file exists
if [ -f "$src_file" ]; then
    # Copy the file to the current directory
    cp "$src_file" .
    echo "'chat.db' has been successfully copied to the current directory."
else
    echo "Error: '$src_file' does not exist."
fi

