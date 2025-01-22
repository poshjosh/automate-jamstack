#!/bin/bash

source ${g_scripts_dir}/functions-util.sh

pkgmgr_add_plugin() {

    local minstalled=false

    debug "Dev: ${2}, installing plugin: ${1}"

    if [ "${2}" = true ]; then
        if [ "$VERBOSE" = true ]; then
            (npm install ${1} --legacy-peer-deps --save-dev --loglevel verbose && minstalled=true)
        else
            (npm install ${1} --legacy-peer-deps --save-dev && minstalled=true)
        fi
    else
        if [ "$VERBOSE" = true ]; then
            (npm install ${1} --legacy-peer-deps --loglevel verbose && minstalled=true)
        else
            (npm install ${1} --legacy-peer-deps && minstalled=true)
        fi
    fi
    if [ "${minstalled}" = true ]; then
        debug "SUCCESS installing plugin: ${1}"
    else
        error " installing plugin: ${1}"
    fi
}

pkgmgr_add() {
    pkgmgr_add_plugin $1 false
}

pkgmgr_add_dev() {
    pkgmgr_add_plugin $1 true
}
