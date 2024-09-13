#!/usr/bin/env bash

set -euo pipefail

[ "${VERBOSE}" = "true" ] || [ "$VERBOSE" = true ] && set -o xtrace

#@echo off

BUILD=${BUILD:-false}
DIR=${DIR:-$(pwd)}
PORT=${PORT:-8000}
SKIP_RUN=${SKIP_RUN:-false}
VERBOSE=${VERBOSE:-false}

function text_has_content() {
    if [ ! -z "$1" -a "$1" != "" ]; then
        echo true
    else
        echo false
    fi
}

if [ "$(text_has_content "$ENV_FILE")" = false ]; then
    echo "ERROR ENV_FILE is required" && exit 1
fi

if [ "$(text_has_content "$IMAGE")" = false ]; then
    echo "ERROR IMAGE is required" && exit 1
fi

cd "${DIR}"

printf "\nWorking directory: %s\n" "${DIR}"

# Build docker image if build=true, or the image doesn't exist

docker images | grep "${IMAGE}" && res="y" || res="n"

if [ "$BUILD" = true ] || [ "$BUILD" = "true" ] || [ "${res}" = "n" ]; then
    printf "\nBuilding image: %s\n" "${IMAGE}"
    docker build -t "${IMAGE}" --progress=plain .
fi

#           input=IMAGE: poshjosh/liveabove3d-latest
# output=container_name: poshjosh-liveabove3d-latest
container_name=$(echo "$IMAGE" | tr / -)

# Stop docker container if it is running
docker ps -a | grep "$container_name" && res="y" || res="n"
if [ "${res}" == "y" ]; then
    printf "\nStopping container: %s" "$container_name"
    # runs the command for 30s, and if it is not terminated, it will kill it after 10s.
    timeout --kill-after=10 30 docker container stop "$container_name"
fi

printf "\nUsing environment file: %s" "${ENV_FILE}"

printf "\nWill mount: %s/app and use port %s" "${DIR}" "${PORT}"

if [ "${SKIP_RUN}" = "true" ] || [ "$SKIP_RUN" = true ]; then
    printf "\nSkipping app run, since SKIP_RUN is true"
else
    printf "\nRunning image: %s" "${IMAGE}"
    docker run --name "$container_name" --rm -v "${DIR}/app":/app \
        --env-file "${ENV_FILE}" \
        -u 0 -p "${PORT}:${PORT}" -e "APP_PORT=$PORT" "${IMAGE}"
fi

printf "\nPruning docker system\n"
docker system prune -f

printf "\nSUCCESS\n"
