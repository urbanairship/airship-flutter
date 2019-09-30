#!/bin/bash

#####################################################
# This script is used for Continuous Integration
#
# Run locally to verify before committing your code.
#
# Options:
#   -a to run Android CI tasks.
#   -i to run iOS CI tasks.
#####################################################

set -o pipefail
set -e
set -x

# get platforms
ANDROID=false
IOS=false

# Parse arguments
OPTS=`getopt hai $*`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h  ) echo -ne "-a to run Android CI tasks.\n-i to run iOS CI tasks.\n  Defaults to both. \n"; exit 0;;
    -a  ) ANDROID=true;;
    -i  ) IOS=true;;
    *   ) break ;;
  esac
  shift
done

# verify flutter is installed
flutter -v

# set up flutter project
if [[ "$BITRISE_SOURCE_DIR" != "" ]]; then
    REPO_PATH="${BITRISE_SOURCE_DIR}"
else
    REPO_PATH=`dirname "${0}"`/../
fi

cd $REPO_PATH
pwd
npm install

# Android
if $ANDROID ; then
    cd example

    # build Android
    PROJECT_PLATFORM_PATH="$(pwd)"

    # Make sure airshipconfig.properties exists
    if [[ ! -f ${PROJECT_PLATFORM_PATH}/app/src/main/assets/airshipconfig.properties ]]; then
      cp -np ${PROJECT_PLATFORM_PATH}/app/src/main/assets/airshipconfig.properties.sample ${PROJECT_PLATFORM_PATH}/app/src/main/assets/airshipconfig.properties || true
    fi

    # Build sample using flutter tool
    flutter build apk --release

    cd ..
fi

# iOS
if $IOS; then
    cd example

    flutter build ios --release --no-codesign

    cd ..
fi