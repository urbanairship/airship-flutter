#!/bin/bash
set -e
set -x

SCRIPT_DIRECTORY="$(dirname "$0")"
ROOT_PATH=$SCRIPT_DIRECTORY/../

PROXY_VERSION=$1

if [ -z "$1" ]
  then
    echo "No proxy version supplied"
    exit 1
fi

# Update Android gradle.properties
sed -i '' "s/\(ext.airship_framework_proxy_version *= *\)\".*\"/\1\"$PROXY_VERSION\"/" "$ROOT_PATH/android/build.gradle"

# Update iOS podspec
sed -i '' "s/\(pod.*AirshipFrameworkProxy.*\)'\([^']*\)'/\1'$PROXY_VERSION'/" "$ROOT_PATH/ios/airship_flutter.podspec"

# Update Package.swift
sed -i '' "s/\(url: \"https:\/\/github.com\/urbanairship\/airship-mobile-framework-proxy.git\", from: \)\"[^\"]*\"/\1\"$PROXY_VERSION\"/" "$ROOT_PATH/Package.swift"
