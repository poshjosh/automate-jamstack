#!/bin/bash

printloc() {

    local msg="Currernt directory: $(pwd)"

    if [ "$VERBOSE" = true ]; then
        debug "$(date '+%T') $msg" & ls -a
    else [ "$PROFILE" == 'dev' ]
        debug "$(date '+%T') $msg";
    fi
}

debug() {
   echo $1
}

trace() {
    if [ "$VERBOSE" = true ]; then debug "$(date '+%T') ${1}"; fi
}

success(){
    debug "    SUCCESS: $1"
}

error() {
    debug "    ERROR: $1"
}

warning() {
    debug "    WARNING: $1"
}

if [ "$PROFILE" = 'prod' ]; then
    g_retry_interval_seconds=2
else
    g_retry_interval_seconds=1
fi

remove_file() {
  if [ -f "$1" ]; then
      debug "Removing: $1"
      local success=false;
      (rm -f $1 && success=true || success=false)
      if [ "$success" = false ]; then
          local timeout_seconds=$g_retry_interval_seconds
          debug "Will retry after $timeout_seconds seconds"
          sleep $timeout_seconds
          debug "Retrying remove of: $1"
          (rm -f $1 && success=true || success=false)
      fi
      if [ "$success" = true ]; then
          succes "Removed: $1"
      else
          error "Failed to remove: $1"
      fi
  fi
}

remove_dir() {
    if [ -d "$1" ]; then
        debug "Removing: $1"
        local success=false;
        (rm -Rf $1 && success=true || success=false)
        if [ "$success" = false ]; then
            local timeout_seconds=$g_retry_interval_seconds
            debug "Will retry after $timeout_seconds seconds"
            sleep $timeout_seconds
            debug "Retrying remove of: $1"
            (rm -Rf $1 && success=true || success=false)
        fi
        if [ "$success" = true ]; then
            succes "Removed: $1"
        else
            error "Failed to remove: $1"
        fi
    fi
}

make_dir() {
    if [ ! -d "$1" ]; then
        debug "Creating: $1"
        local success=false;
        (mkdir -p $1 && success=true || success=false)
        if [ "$success" = false ]; then
            local timeout_seconds=$g_retry_interval_seconds
            debug "Will retry after $timeout_seconds seconds"
            sleep $timeout_seconds
            debug "Retrying create: of $1"
            (mkdir -p $1 && success=true || success=false)
        fi
        if [ "$success" = true ]; then
            succes "Created: $1"
        else
            error "Failed to create: $1"
        fi
    fi
}

create_dir() {
    make_dir $1
}

empty_dir() {
    if [ -d "$1" ]; then
        debug "Emptying: $1"
        local success=false;
        (rm -Rf "$1/*" && success=true || success=false)
        if [ "$success" = false ]; then
            local timeout_seconds=$g_retry_interval_seconds
            debug "Will retry after $timeout_seconds seconds"
            sleep $timeout_seconds
            debug "Retrying empty of: $1"
            (rm -Rf "$1/*" && success=true || success=false)
        fi
        if [ "$success" = true ]; then
            succes "Emptied: $1"
        else
            error "Failed to empty: $1"
        fi
    fi
}

# If dir exists empty it, otherwise create it
provide_empty_dir() {
    if [ -d "$1" ]; then
        empty_dir $1
    else
        create_dir $1
    fi
}

##############################
#       NOT YET TESTED       #
##############################
# Execute the function (arg 1) using argument (arg 2) and if it fails, retry
# once after timeout in seconds speicifed by arg 3
# arg 1 - function to execute
# arg 2 - single argument to function to execute
# arg 3 - timeout in seconds between first and second try
try_func() {
    ($1 $2 && success=true || success=false)
    if [ "$success" = false ]; then
        local timeout_seconds=$3
        "Will retry after $timeout_seconds seconds"
        sleep $timeout_seconds
        ($1 $2 && success=true || success=false)
    fi
    if [ "$success" = true ]; then
        succes "$1 on $2"
    else
        error "$1 on $2"
    fi
}

string_length() {
    local slen=$(echo -n $1 | wc -m)
    debug "Length: $slen of text: $1"
    echo $slen
}

to_reference_fmt() {
    debug "\${${1}}"
}

# Arg 0 - content to write e.g "Hello World"
# Arg 1 - directory name   e.g /jumping/jack/flash
# Arg 2 - file name        e.g /test.txt
write_to_file() {
    make_dir $2
    echo "$1" > $3
}

# Arg 1 - text to extract date from
# Arg 2 - seperator for date (e.g -) will be applied thus: 2014-10-13 etc
extract_date_having_separator() {
    # dddd-dd-dd
    local regex1=$(debug "\b[[:digit:]]{4}$2[[:digit:]]{2}$2[[:digit:]]{2}\b")
    local found=$(echo $1 | grep -Eo $regex1)
    if [ -z "$found" ]; then
        # dd-dd-dddd
        local regex2=$(debug "\b[[:digit:]]{2}$2[[:digit:]]{2}$2[[:digit:]]{4}\b")
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

move_to_parent_directory() {
    local msg="Moving up one level: $1"
    trace $msg
    (mv $1 .. && return_value_move_to_parent_directory=true || return_value_move_to_parent_directory=false)
    if [ "$return_value_move_to_parent_directory" = true ]; then
        success "$msg"
    else
        error "$msg"
    fi
}

move_dir_content_to_parent() {

    debug "Moving content of current directory up one level"

    printloc

    debug "For this process, IGNORE THIS WARNING -> mv: can't rename '.': Resource busy"

    find . -maxdepth 1 -exec mv {} .. \;

    (cd .. && printloc)
}

move_dir_content_to_parent_1() {

    debug "Moving content of current directory up one level"

    printloc

#    debug "For this process, IGNORE THIS WARNING -> mv: can't rename '.': Resource busy"
#    find . -maxdepth 1 -exec mv {} .. \;

    local files=$(find . -maxdepth 1)
    for item in ${files[*]}
    do

        local fname=$(echo ${item})

        if [ "$fname" == '.' ] || [ "$fname" == '..' ]; then
            debug "Skipping $fname"
            continue
        fi

        move_to_parent_directory $fname

        if [ "$return_value_move_to_parent_directory" = false ]; then
            local timeout_seconds=5
            debug "Will retry after $timeout_seconds seconds"
            sleep $timeout_seconds
            debug "...Retrying move up one level for: $fname"
            move_to_parent_directory $fname
        fi
    done

    (cd .. && printloc)
}

emplace_zip_file_content_and_delete_zip_file() {

    local files=$(find "${1}" -maxdepth 1)
    local file_count=${#files[@]}
    debug "Found $file_count files in current directory"

    if [ $file_count == 1 ]; then
        local dir=''
        for item in ${files[*]}
        do
            local fname=$(echo ${item})
            trace "$fname"

            if [ "$fname" == '.' ] || [ "$fname" == '..' ]; then
                debug "Skipping file: $fname"
            elif [ "$fname" == "$1" ]; then
                debug "Skipping $fname"
            elif [[ ${fname} == *.zip ]]; then
                remove_file "${fname}"
            elif [ -d "$fname" ]; then
                debug "Found directory: $fname"
                dir=$fname
            else
                warning "What would you have me do with this file? $fname"
            fi
        done

        if [ "$dir" == '' ]; then
            error "Directory unpacked from .zip file not found"
        else
            (cd ${dir} && move_dir_content_to_parent)
            remove_dir ${dir}
        fi
    fi

    (cd ${1} && (debug "Removing zip files in: $1" & rm -Rf *.zip))
}

# arg 1 - source to download from
# arg 2 - target to download to
download_and_unzip_into_dir() {

    local msg="Downloading from: ${1}"

    (cd ${2} && curl -LO $1) && success "$msg" || error "$msg"

    (cd ${2} && printloc)

    if [[ ${1} == *.zip ]]; then

        msg="Unzipping downloaded content into: ${2}"
        debug "${msg}"

        (cd ${2} && unzip *.zip) && success "$msg" || error "$msg"
    fi

    emplace_zip_file_content_and_delete_zip_file ${2}

    (cd ${2} && printloc)
}

# arg 1 - source to clone from
# arg 2 - target to clone to
git_clone_into_dir() {

    local msg="Performing git clone from ${1} into: ${2}"

    debug "${msg}"

    git clone ${1} ${2} && success "$msg" || error "$msg"

    (cd ${2} && rm -Rf *.git)

    (cd ${2} && printloc)
}

# arg 1 - source to copy from
# arg 2 - target to copy to
copy_dir_contents() {

    local msg="Copying directory contents from ${1} to ${2}"
    debug "${msg}"

    (cd ${1} && printloc)

    cp -R "${1}/." ${2} && success "$msg" || error "$msg"

    (cd ${2} && printloc)
}

# arg 1 - source to import from (Will be created if it doesn't exist)
# arg 2 - target to import to
import() {

    make_dir $2

    if [ -d "${2}" ]; then

        if [[ ${1} == http* ]]; then

            if [[ ${1} == *.git ]]; then

                git_clone_into_dir ${1} ${2}

            else

                download_and_unzip_into_dir ${1} ${2}
            fi
        else

            copy_dir_contents ${1} ${2}
        fi
    else
        "    WARNING: Due to previous errors, content will not be imported from $1 to $2"
    fi
}
