#!/usr/bin/env bash
set -euxo pipefail

SCRIPT_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
ROOT_PATH="$SCRIPT_DIRECTORY/.."

PROXY_VERSION="$1"
if [ -z "$PROXY_VERSION" ]; then
    echo "No proxy version supplied"
    exit 1
fi

sed -i.bak -E "s/(ext\.airship_framework_proxy_version *= *')([^']*)(')/\1$PROXY_VERSION\3/" "$ROOT_PATH/android/build.gradle"
sed -i.bak -E "s/(s\.dependency *\"AirshipFrameworkProxy\", *\")([^\"]*)(\")/\1$PROXY_VERSION\3/" "$ROOT_PATH/ios/airship_flutter.podspec"

find "$ROOT_PATH" -name "*.bak" -delete
