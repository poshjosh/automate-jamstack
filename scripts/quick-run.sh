#!/usr/bin/env bash

set -euo pipefail

#@echo off

printf "\nEnter site name without http://, e.g my-site.com\n"

read -r SITE_NAME

export BUILD=true
export DIR="${HOME}/dev_looseboxes/automate/automate-jamstack"
export ENV_FILE="${DIR}/app/sites/${SITE_NAME}.env"
export IMAGE="poshjosh/automate-jamstack"
export PORT=8000
export SKIP_RUN=false
export VERBOSE=false

source ./docker-run-app.sh

read -n 1 -s -r -p "Press any key to continue"