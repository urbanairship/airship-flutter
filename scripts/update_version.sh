#!/bin/bash -ex
SCRIPT_DIRECTORY=$(dirname "${0}")
ROOT_PATH=$(dirname "${0}")/../

VERSION=$1

if [ -z "$1" ]
  then
    echo "No version supplied"
    exit
fi

# Update AirshipPluginVersion classes with current plugin version
sed -i '' "s/\(pluginVersion *= *\)\".*\"/\1\"$VERSION\"/g" "$ROOT_PATH/ios/Classes/AirshipPluginVersion.swift"
sed -i '' "s/\(AIRSHIP_PLUGIN_VERSION *= *\)\".*\"/\1\"$VERSION\"/g" "$ROOT_PATH/android/src/main/kotlin/com/airship/flutter/AirshipPluginVersion.kt"

# Update podspec
sed -i '' "s/\(^AIRSHIP_FLUTTER_VERSION *= *\)\".*\"/\1\"$VERSION\"/g" "$ROOT_PATH/ios/airship_flutter.podspec"

# Update readme
sed -i '' "s/\(^  airship_flutter *: *\).*/\1\^$VERSION/g" "$ROOT_PATH/README.md"