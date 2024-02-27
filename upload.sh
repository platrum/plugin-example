#!/usr/bin/env bash

if [[ $PLATRUM_HOST == "" ]]; then
  PLATRUM_HOST=https://app.platrum.ru
fi

if [[ $PLATRUM_API_KEY == "" ]]; then
  printf "PLATRUM_API_KEY bash variable should be specified\n"
  exit 1
fi

if [[ $PLATRUM_API_PROJECT == "" ]]; then
  printf "PLATRUM_API_PROJECT bash variable should be specified\n"
  exit 1
fi

if [[ $1 == "" ]]; then
  printf "Usage: ./upload.sh {plugin_name}\n"
  exit 1
fi

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

PLATRUM_AUTH="key=${PLATRUM_API_KEY}&project=${PLATRUM_API_PROJECT}"
PLUGIN_NAME=plugin-${1}

dir=$(realpath)
printf "\n\n"

set -e

"${dir}/yarn.sh" install

docker run -it --rm \
  -v "${dir}/frontend:/app/src" \
  -v "${dir}/assets/bundle:/assets" \
  -e NODE_ENV=production \
  -e HASH_NAMES=0 \
  -e PLUGIN_NAME="${PLUGIN_NAME}" \
  -w /app \
  platrum/builder yarn plugin

printf "\n\n"

zip -r "${PLUGIN_NAME}".zip assets config frontend

printf "\n\n"

curl "${PLATRUM_HOST}/plugins/api/plugin/upload?${PLATRUM_AUTH}" \
  -H 'Content-Type: application/json' \
  --data-binary "@./${PLUGIN_NAME}.zip"
  
printf "\n\n"
