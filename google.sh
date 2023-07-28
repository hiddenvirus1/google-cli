#!/bin/bash

echo -n -e '''\033[92m _____                   _                 _ _ 
|  __ \                 | |               | (_)
| |  \/ ___   ___   __ _| | ___ ______ ___| |_ 
| | __ / _ \ / _ \ / _` | |/ _ \______/ __| | |
| |_\ \ (_) | (_) | (_| | |  __/     | (__| | |
 \____/\___/ \___/ \__, |_|\___|      \___|_|_|
                    __/ |    FB/Sharif Ansari
                   |___/\033[0m
 
 '''

search_query=""
output=""

function cleanup {
    if [ -n "$output_file" ] && [ -f "$output_file" ]; then
        echo -e "\nSearch interrupted. Search results saved to \033[1;96m$output_file\033[0m"
    fi
    exit 1
}

trap cleanup SIGINT

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -s|--search)
            search_query="$2"
            shift
            shift
            ;;
        -o|--output)
            output_file="$2"
            shift
            shift
            ;;
        -h|--help)
            echo -e "\nUsage: bash google.sh [options]\n"
            echo "Options:"
            echo " -s, --search    Specifies the search query for Google search."
            echo "                          Single Search: site:google.com"
            echo "                          Multiple Search: site:google.com \"ext:php\" (use quotes)"
            echo " -o, --output                  Output file path"
            echo " -h, --help                    Show this help message"
            exit 0
            ;;
        *)  # Unknown option
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "$search_query" ]; then
    echo -e "\nUsage: bash google.sh [options]\n"
    echo "Options:"
    echo " -s, --search    Specifies the search query for Google search."
    echo "                          Single Search: site:google.com"
    echo "                          Multiple Search: site:google.com \"ext:php\" (use quotes)"
    echo " -o, --output                  Output file path"
    echo " -h, --help                    Show this help message"
    exit 1
fi

if [ -z "$output_file" ]; then
    search_query_encoded=$(echo "$search_query" | tr ' ' '+')
    for i in {0..100..10}; do
        output=$(curl -s -A "Mozilla/5.0" "https://www.google.com/search?q=$search_query_encoded&start=$i" | grep -oE 'https?://[^ &"]+[^ &"\t]' | grep -vE '(google\.com|googleusercontent\.com)')
        if [ -z "$output" ]; then
            echo -e "\nNo more search results. \033[1;91mExiting...\033[0m"
            break
        fi
        echo "$output"
    done
else
    search_query_encoded=$(echo "$search_query" | tr ' ' '+')
    for i in {0..100..10}; do
        output=$(curl -s -A "Mozilla/5.0" "https://www.google.com/search?q=$search_query_encoded&start=$i" | grep -oE 'https?://[^ &"]+[^ &"\t]' | grep -vE '(google\.com|googleusercontent\.com)')
        if [ -z "$output" ]; then
            echo -e "\nNo more search results. \033[1;91mExiting...\033[0m"
            break
        fi
        echo "$output"
        echo "$output" >> "$output_file"
    done
    echo -e "Search results saved to \033[1;96m$output_file\033[0m"
fi

