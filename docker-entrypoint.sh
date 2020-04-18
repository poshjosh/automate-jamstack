#!/bin/bash

echo "Running setup scripts"

# ls -a
# . .. .dockerenv bin data dev docker-entrypoint.sh ect home lib
# media mnt opt proc root run sbin sites srv sys tmp usr var

# Change to the /sites directory, which is our working directory
# The /sites directory contains node_modules and package.json
cd sites

if [ "$VERBOSE" = true ]; then
    echo "$(date) Working directory: $(pwd)"
    ls -a
    echo "-------------------------"
    cd ${SITE_DIR_NAME}
    echo "$(date) Working directory: $(pwd)"
    ls -a
    echo "-------------------------"
    cd ..
    cd setup-scripts
    echo "$(date) Working directory: $(pwd)"
    ls -a
    echo "-------------------------"
    cd ..
    echo "$(date) Working directory: $(pwd)"
    ls -a
    echo "-------------------------"
fi

chmod +x ./setup-scripts/setup.sh

/bin/bash ./setup-scripts/setup.sh
