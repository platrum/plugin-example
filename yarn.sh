#!/usr/bin/env bash

if [[ $1 == "" ]]; then
  printf "Usage: ./yarn.sh add {package}\n"
  exit 1
fi

realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

dir=$(realpath)
printf "\n\n"

set -e

if [ ! "$1" == "install" ]; then
  if ! test -f "${dir}/frontend/package.json"; then
    docker run -it --rm \
      -v "${dir}/frontend:/app/src" \
      -w /app/src \
      platrum/builder yarn init -s --non-interactive -y
  fi
fi

docker run -it --rm \
  -v "${dir}/frontend:/app/src" \
  -w /app/src \
  platrum/builder yarn "$@"
