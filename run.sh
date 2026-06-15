#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 <filename.csv>"
    exit 1
fi
FILE=$1
echo "Student: Percentage (Grade)"
echo "--------------------------"
awk -F',' -f task6.awk "$FILE" | sort