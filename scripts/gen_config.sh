#!/bin/bash

ROOT_PATH=$(dirname "${0}")/../

flutterConfigDir="$ROOT_PATH/lib/src/config"
export  protoFile="$flutterConfigDir/config.proto"

kotlin_out="$ROOT_PATH/android/src/main/kotlin/"
# com/airship/flutter/config
swift_out="$ROOT_PATH/ios/Classes/Config"

protoc -I="$flutterConfigDir" --dart_out="$flutterConfigDir" "$protoFile"

protoc -I="$flutterConfigDir" --java_out="$kotlin_out" --kotlin_out="$kotlin_out" "$protoFile"

protoc -I="$flutterConfigDir" --swift_out="$swift_out" "$protoFile"