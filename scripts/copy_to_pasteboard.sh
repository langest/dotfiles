#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

filename="$1"

if ! command -v xclip &> /dev/null; then
    echo "xclip not found. Please install it and try again."
    exit 1
fi

total_lines=$(wc -l < "$filename")
current_line=1

while [ $current_line -le $total_lines ]; do
    end_line=$((current_line + 499))
    if [ $end_line -gt $total_lines ]; then
        end_line=$total_lines
    fi

    echo "Copying lines $current_line to $end_line from $filename to pasteboard..."
    sed -n "${current_line},${end_line}p" "$filename" | xclip -selection clipboard

    current_line=$((end_line + 1))
    if [ $current_line -le $total_lines ]; then
        read -p "Press ENTER to copy the next 500 lines, or Ctrl+C to exit..."
    fi
done

echo "Finished copying the contents of $filename."

