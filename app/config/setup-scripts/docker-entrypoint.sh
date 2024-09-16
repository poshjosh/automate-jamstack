#!/bin/bash

# Change to the /app directory, which is our working directory
#
if [ "$VERBOSE" = true ]; then
    echo "Current directory: $(pwd)"
    echo "Changing to directory: $(pwd)/app"
fi

cd app || exit 1

if [ "$VERBOSE" = true ]; then
    ls -a
    echo "-------------------------"
    echo "cd ./config/setup-scripts" && cd "./config/setup-scripts" || exit 1
    echo "scripts directory: $(pwd)"
    ls -a
    echo "-------------------------"
    echo "cd .. " && cd .. && echo "cd ./terraform" && cd "./terraform" || exit 1
    echo "terraform directory: $(pwd)"
    ls -a
    echo "-------------------------"
    echo "cd .." && cd .. && echo "cd .." && cd ..
    echo "app directory: $(pwd)"
    ls -a
fi

chmod +x ./config/setup-scripts/setup.sh

/bin/bash ./config/setup-scripts/setup.sh
