#!/bin/bash

#@echo off

#todo Prompt user to enter site name

# Type: mysite.com not: http://mysite.com
site_name=chinomsoikwuagwu.com

app_dir="${HOME}/dev_chinomso/automate-jamstack"

env_file="${app_dir}/app/sites/${site_name}.env"

echo "Changing to app directory: ${app_dir}"

cd ${app_dir}

# Build docker image if it doesn't exist

docker images | grep "poshjosh/automate-jamstack" && res="y" || res="n"

if [ "${res}" == "n" ]; then
    echo "Building image poshjosh/automate-jamstack"
    docker build -t poshjosh/automate-jamstack .
fi

# Stop docker container if it is running

docker ps -a | grep "poshjosh-automate-jamstack" && res="y" || res="n"
if [ "${res}" == "y" ]; then
    echo "Stopping container poshjosh-automate-jamstack"
    docker container stop poshjosh-automate-jamstack
    echo "Waiting 7 seconds"
    timeout /t 7
fi

echo "Running image poshjosh/automate-jamstack"

echo "Using environment file ${env_file}"

echo "Mounting: ${app_dir}/app"

docker run --name poshjosh-automate-jamstack --rm -v "${app_dir}/app":/app \
    --env-file ${env_file} \
    -u 0 -p 8000:8000 -e APP_PORT=8000 poshjosh/automate-jamstack

docker system prune -f

echo "DONE"

read -n 1 -s -r -p "Press any key to continue"
