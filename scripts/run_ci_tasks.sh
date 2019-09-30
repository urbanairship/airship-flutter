#!/bin/bash

#####################################################
# This script is used for Continuous Integration
#
# Run locally to verify before committing your code.
#
# Options:
#   -z to run Flutter Analysis
#   -a to run Android CI tasks.
#   -i to run iOS CI tasks.
#####################################################

set -o pipefail
set -e

# get platforms
ANDROID=true
ANALYZE=true
IOS=true

# Parse arguments
OPTS=`getopt haiz $*`
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

while true; do
  case "$1" in
    -h  ) echo -ne "-a to run Android CI tasks.\n-i to run iOS CI tasks.\n -z to run Flutter analysis tasks.\n  Defaults to all. \n"; exit 0;;
    -z  ) ANALYZE=true;ANDROID=false;IOS=false;;
    -a  ) ANDROID=true;IOS=false;ANALYZE=false;;
    -i  ) IOS=true;ANDROID=false;ANALYZE=false;;
    *   ) break ;;
  esac
  shift
done

# verify flutter is installed and correctly configured
flutter --version
flutter doctor

# set up flutter project
if [[ "$BITRISE_SOURCE_DIR" != "" ]]; then
    REPO_PATH="${BITRISE_SOURCE_DIR}"
else
    REPO_PATH=`dirname "${0}"`/../
fi

cd $REPO_PATH
pwd

# Flutter Analysis
if $ANALYZE; then
    flutter analyze
fi

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