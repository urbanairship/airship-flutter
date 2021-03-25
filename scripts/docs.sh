#!/bin/bash

#####################################################
# This script is used for Continuous Integration
#
# Run locally to verify before committing your code.
#
# Options:
#   -g to generate documentation.
#   -u to upload documentation to google cloud.
#
#####################################################

set -o pipefail
set -e

# get platforms
GENERATE=false
UPLOAD=false

while true; do
  case "$1" in
    -g  ) GENERATE=true;;
    -u  ) UPLOAD=true;;
    *   ) break ;;
  esac
  shift
done

# Generate doc
if $GENERATE; then
  $FLUTTER_ROOT/bin/cache/dart-sdk/bin/dartdoc
fi

# Upload doc
if $UPLOAD; then

    if [ -z "$1" ]; then
        echo "No version supplied"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Missing docs $2"
        exit 1
    fi

    ROOT_PATH='dirname "${0}"'/..
    TAR_NAME="$1.tar.gz"

    cd "$2"
    tar -czf $TAR_NAME *
    cd -

    gsutil cp "$ROOT_PATH/$2/$TAR_NAME" gs://ua-web-ci-prod-docs-transfer/libraries/flutter/$TAR_NAME

fi
