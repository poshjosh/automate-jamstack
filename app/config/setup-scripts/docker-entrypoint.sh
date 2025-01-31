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

use_space_if_env_variable_unset() {
    input=$(printenv "$1")
    if [ -z "$input" ]; then
        export "${1}="
    fi
}

use_space_if_env_variable_unset SITE_FACEBOOK_HANDLE
use_space_if_env_variable_unset SITE_INSTAGRAM_HANDLE
use_space_if_env_variable_unset SITE_LINKEDIN_HANDLE
use_space_if_env_variable_unset SITE_REDDIT_HANDLE
use_space_if_env_variable_unset SITE_TIKTOK_HANDLE
use_space_if_env_variable_unset SITE_TWITTER_HANDLE
use_space_if_env_variable_unset SITE_YOUTUBE_HANDLE

chmod +x ./config/setup-scripts/setup.sh

/bin/bash ./config/setup-scripts/setup.sh
