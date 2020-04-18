#!/bin/bash

printloc() {

    local msg="Currernt directory: $(pwd)"

    if [ "$VERBOSE" = true ]; then
        echo "$(date '+%T') $msg" & ls -a
    else [ "$PROFILE" == 'dev' ]
        echo "$(date '+%T') $msg";
    fi
}

trace() {
    if [ "$VERBOSE" = true ]; then echo "$(date '+%T') ${1}"; fi
}

# Arg 0 - content to write e.g "Hello World"
# Arg 1 - directory name   e.g /jumping/jack/flash
# Arg 2 - file name        e.g /test.txt
write_to_file() {
    if [ ! -d "$2" ]; then
        mkdir -p $2
    fi
    echo "$1" > $3
}

# Arg 1 - text to extract date from
# Arg 2 - seperator for date (e.g -) will be applied thus: 2014-10-13 etc
extract_date_having_separator() {
    # dddd-dd-dd
    local regex1=$(echo "\b[[:digit:]]{4}$2[[:digit:]]{2}$2[[:digit:]]{2}\b")
    local found=$(echo $1 | grep -Eo $regex1)
    if [ -z "$found" ]; then
        # dd-dd-dddd
        local regex2=$(echo "\b[[:digit:]]{2}$2[[:digit:]]{2}$2[[:digit:]]{4}\b")
        found=$(echo $1 | grep -Eo $regex2)
    fi
    echo $found
}

# Arg 1 - The text to extract date from
# Supported separators /, -, \, _ e.g for / is 2014/10/23
extract_date() {
    local mfound=$(extract_date_having_separator $1 '/')
    if [ -z "$mfound" ]; then
        mfound=$(extract_date_having_separator $1 '-')
        if [ -z "$mfound" ]; then
            mfound=$(extract_date_having_separator $1 '\')
            if [ -z "$mfound" ]; then
                mfound=$(extract_date_having_separator $1 '_')
            fi
        fi
    fi
    echo $mfound
}
