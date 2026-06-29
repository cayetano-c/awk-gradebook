#!/bin/bash
# Task 7 - Bash Wrapper for AWK Gradebook

if [ -z "$1" ]; then
    echo "Usage: $0 <filename.csv>"
    exit 1
fi

FILE=$1

printf "%-10s %7s %s\n" "Name" "Percent" "Letter"
awk -F',' -f task6.awk "$FILE" | sort