#!/bin/bash

# Change to the /app directory, which is our working directory
#
cd app

if [ "$VERBOSE" = true ]; then
    echo "app directory: $(pwd)"
    ls -a
    echo "-------------------------"
    echo "cd ./config/setup-scripts" && cd "./config/setup-scripts"
    echo "scripts directory: $(pwd)"
    ls -a
    echo "-------------------------"
    echo "cd .. " && cd .. && echo "cd ./terraform" && cd "./terraform"
    echo "terraform directory: $(pwd)"
    ls -a
    echo "-------------------------"
    echo "cd .." && cd .. && echo "cd .." && cd ..
    echo "app directory: $(pwd)"
    ls -a
fi

chmod +x ./config/setup-scripts/setup.sh

/bin/bash ./config/setup-scripts/setup.sh
