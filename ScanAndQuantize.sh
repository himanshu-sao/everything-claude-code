#!/bin/bash

# ==============================================================================
# Script: ScanAndQuantize.sh
# Description: Scans a log file to calculate statistics (Lines, Words, Chars) 
#              and provides a word-frequency quantization.
# Author: Nexus Tech-Lead (v1.11.0)
# ==============================================================================

# --- Functions ---

usage() {
    echo "Usage: $0 [log_file_path]"
    echo ""
    echo "Arguments:"
    echo "  log_file_path    The absolute or relative path to the log file to analyze."
    echo ""
    echo "Options:"
    echo "  -h, --help       Show this help message and exit."
    exit 1
}

# --- Validation ---

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    usage
fi

# Check for exactly one argument
if [ "$#" -ne 1 ]; then
    echo "Error: Exactly one argument is required."
    usage
fi

LOG_FILE="$1"

# Check if file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' does not exist."
    exit 1
fi

# Check if file is readable
if [ ! -r "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' is not readable."
    exit 1
fi

# --- Core Logic ---

echo "----------------------------------------------------------"
echo "📊 Nexus Log Quantizer: $(basename "$LOG_FILE")"
echo "----------------------------------------------------------"

# 1. Basic Stats
echo "[*] Calculating basic statistics..."
STATS=$(wc "$LOG_FILE")
LINES=$(echo "$STATS" | awk '{print $1}')
WORDS=$(echo "$STATS" | awk '{print $2}')
CHARS=$(echo "$STATS" | awk '{print $3}')

echo "    - Lines:      $LINES"
echo "    - Words:      $WORDS"
echo "    - Characters: $CHARS"

# 2. Top 10 Most Frequent Words
echo ""
echo "[*] Top 10 Frequent Words (Quantization):"
# This pipeline:
# - tr: converts all non-alphanumeric to spaces
# - tr: converts spaces to newlines
# - grep: removes empty lines
# - sort: sorts words
# - uniq -c: counts occurrences
# - sort -rn: sorts by frequency descending
# - head -n 10: takes top 10
tr -c '[:alnum:]' '[\n*]' < "$LOG_FILE" | grep -v '^$' | sort | uniq -c | sort -rn | head -n 10 | awk '{printf "    %-10s : %d occurrences\n", $2, $1}'

echo "----------------------------------------------------------"
echo "Done."
