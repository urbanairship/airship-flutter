#!/bin/bash

#####################################################
# This script is used for Continuous Integration
#
# Run locally to verify before committing your code.
#
# Options:
#   -g to generate documentation.
#   -p to create a tar.gz docs package.
#
#####################################################

set -o pipefail
set -e

# get platforms
GENERATE=false
PACKAGE=false

while true; do
  case "$1" in
    -g  ) GENERATE=true;;
    -p  ) PACKAGE=true;;
    -gp ) GENERATE=true;PACKAGE=true;;
    *   ) break ;;
  esac
  shift
done

# Generate doc
if $GENERATE; then
  flutter pub get
  flutter pub global activate dartdoc
  flutter pub global run dartdoc --exclude 'dart:async,dart:collection,dart:convert,dart:core,dart:developer,dart:ffi,dart:html,dart:io,dart:isolate,dart:js,dart:js_util,dart:math,dart:typed_data,dart:ui'
fi

# Package doc
if $PACKAGE; then
    if [ -z "$1" ]; then
        echo "No version supplied"
        exit 1
    fi

    if [ ! -d "$2" ]; then
        echo "Missing docs $2"
        exit 1
    fi

    TAR_NAME="../$1.tar.gz"

    cd "$2"
    tar -czf $TAR_NAME *
    cd -
fi
