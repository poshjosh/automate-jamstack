#!/bin/bash

source ./setup-scripts/functions-util.sh

# arg 1 - source dir
#         Files in the source dir will overwrite files in target dir
#
# arg 2 - target dir
#         Files in the target dir will be backed up ONLY if a backup does not
#         already exist. This means the backup will contain the original state.
#
backup_and_replace_files() {

    local src=$1
    if [[ ${src} == /* ]]; then src="${src:1}"; fi # remove first char
    if [[ ${src} == ./* ]]; then src="${src:2}"; fi # remove first 2 chars
    trace "Formatted $1 to $src"

    local tgt=$2
    if [[ ${tgt} == /* ]]; then tgt="${tgt:1}"; fi # remove first char
    if [[ ${tgt} == ./* ]]; then tgt="${tgt:2}"; fi # remove first 2 chars
    trace "Formatted $2 to $tgt"

    local files=$(find "./${src}" -type f)
    for item in ${files[*]}
    do

        local tgtname=$(echo ${item} | sed -e "s^/${src}/^/${tgt}/^g")
        local backupname=$(echo ${item} | sed -e "s^/${src}/^/${tgt}/backups/^g")

        # Make a backup of original ONLY if a backup has not been made
        #
        if [ -f "$tgtname" ] && [ ! -f "$backupname" ]; then
            printf "\nCopying: %1s to: %2s\n" $tgtname $backupname
            cp $tgtname $backupname
        fi

        # Update original with custom
        #
        printf "Copying: %1s to: %2s\n" $item $tgtname
        cp $item $tgtname

    done
}

# arg 1 - target file
# arg 2 - to-replace
# arg 3 - replacement
#
find_and_replace_text_in_file() {
    sed -i "s^${2}^${3}^g" $1 && trace "  Updated all ${2} to ${3} in $1"
}

# arg 1 - target dir
# arg 2 - to-replace
# arg 3 - replacement
#
find_and_replace_text_in_dir() {

    local tgt=$1
    if [[ ${tgt} == /* ]]; then tgt="${tgt:1}"; fi # remove first char
    if [[ ${tgt} == ./* ]]; then tgt="${tgt:2}"; fi # remove first 2 chars
    trace "Formatted $2 to $tgt"

    if [ -d "./$tgt" ]; then

        local files=$(find "./${tgt}" -type f)
        for item in ${files[*]}
        do

            local tgtname=$(echo ${item})

            find_and_replace_text_in_file $tgtname ${2} ${3}
        done

    else
        trace "Directory not found. Find and replace will not be carried out for $tgt"
    fi
}

# Like method find_and_replace_text_in_dir, but restricts the files that will be
# searched in the target dir to those existing in the source dir.
#
# arg 1 - source dir
# arg 2 - target dir
# arg 3 - to-replace
# arg 4 - replacement
#
find_and_replace_text_in_dir_mirror() {

    local src=$1
    if [[ ${src} == /* ]]; then src="${src:1}"; fi # remove first char
    if [[ ${src} == ./* ]]; then src="${src:2}"; fi # remove first 2 chars
    trace "Formatted $1 to $src"

    local tgt=$2
    if [[ ${tgt} == /* ]]; then tgt="${tgt:1}"; fi # remove first char
    if [[ ${tgt} == ./* ]]; then tgt="${tgt:2}"; fi # remove first 2 chars
    trace "Formatted $2 to $tgt"

    if [ -d "./$src" ] && [ -d "./$tgt" ]; then

        local files=$(find "./${src}" -type f)
        for item in ${files[*]}
        do

            local tgtname=$(echo ${item} | sed -e "s^/${src}/^/${tgt}/^g")

            echo "find_and_replace_text_in_dir_mirror $1, $2, $3 = $4"

            find_and_replace_text_in_file $tgtname "${3}" "${4}"
        done
    else
        trace "One or more of the directories not found. Find and replace will not be carried out for $tgt."
    fi
}

custom_find_and_replace() {

    trace "custom_find_and_replace $1 = $2"

    if [ -z ${2+x} ] || [ "$2" == '' ]; then
        trace "Value not set for $1"
    else
        #@TODO ensure replacement took place by serching for the variable that
        # was replaced
        find_and_replace_text_in_dir_mirror "site-root/${SITE_DIR_NAME}" ${SITE_DIR_NAME} "$1" "$2"
    fi
}
