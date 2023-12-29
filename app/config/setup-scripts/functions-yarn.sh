#!/bin/bash

source ${g_scripts_dir}/functions-util.sh

pkgmgr_add_plugin() {

    local minstalled=false

    echo "Dev: ${2}, installing plugin: ${1}"

    if [ "${2}" = true ]; then
        (npm install ${1} --save-dev && minstalled=true)
    else
        (npm install ${1} && minstalled=true)
    fi
    if [ "${minstalled}" = true ]; then
        echo "  SUCCESS installing plugin: ${1}"
    else
        echo "  ERROR installing plugin: ${1}"
    fi
}

pkgmgr_add() {
    pkgmgr_add_plugin $1 false
}

pkgmgr_add_dev() {
    pkgmgr_add_plugin $1 true
}
