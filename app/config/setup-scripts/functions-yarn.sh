#!/bin/bash

source ${g_scripts_dir}/functions-util.sh

yarn_add_plugin() {

    local minstalled=false

    debug "Dev: ${2}, installing plugin: ${1}"

    if [ "${2}" = true ]; then
        (yarn add ${1} --dev && minstalled=true)
    else
        (yarn add ${1} && minstalled=true)
    fi
    if [ "${minstalled}" = true ]; then
        debug "  SUCCESS installing plugin: ${1}"
    else
        debug "  ERROR installing plugin: ${1}"
    fi
}

yarn_add() {
    yarn_add_plugin $1 false
}

yarn_add_dev() {
    yarn_add_plugin $1 true
}

install_plugin() {

    yarn_add_plugin $1 $2
}

install_plugin_if_not_installed() {
    local plugin_install_dir="${1}/node_modules/${2}"
    if [ -d "$plugin_install_dir" ] && [ "$(ls -A $plugin_install_dir)" ]; then
        debug "Plugin already installed: ${2}"
    else
        (cd ${1} && install_plugin ${2} ${3}) # the enclosing bracket keeps the change directory within context
    fi
}
