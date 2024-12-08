#!/bin/bash
set -e
set -x

SCRIPT_DIRECTORY="$(dirname "$0")"
ROOT_PATH=$SCRIPT_DIRECTORY/../

FLUTTER_VERSION=$1
PROXY_VERSION=$2
IOS_VERSION=$3
ANDROID_VERSION=$4

if [ -z "$FLUTTER_VERSION" ] || [ -z "$PROXY_VERSION" ]; then
    echo "Error: Flutter and Proxy versions are required"
    exit 1
fi

RELEASE_DATE=$(date +"%B %-d, %Y")

# Create changelog entry
NEW_ENTRY="## Version $FLUTTER_VERSION - $RELEASE_DATE\n\n"

if [ -n "$IOS_VERSION" ] && [ -n "$ANDROID_VERSION" ]; then
    NEW_ENTRY+="Minor release that updates to latest SDK versions.\n\n"
    NEW_ENTRY+="### Changes\n"
    NEW_ENTRY+="- Updated Android SDK to $ANDROID_VERSION\n"
    NEW_ENTRY+="- Updated iOS SDK to $IOS_VERSION\n"
    NEW_ENTRY+="- Updated airship-mobile-framework-proxy to $PROXY_VERSION"
else 
    NEW_ENTRY+="Minor release that updates the airship-mobile-framework-proxy.\n\n"
    NEW_ENTRY+="### Changes\n"
    NEW_ENTRY+="- Updated airship-mobile-framework-proxy to $PROXY_VERSION"
fi

# Create temporary file with new content
TEMP_FILE=$(mktemp)

# Add the header line
echo "# Flutter Plugin Changelog" > "$TEMP_FILE"
echo -e "\n$NEW_ENTRY\n" >> "$TEMP_FILE"

# Append the rest of the existing changelog (skipping the header)
tail -n +2 "$ROOT_PATH/CHANGELOG.md" >> "$TEMP_FILE"

# Replace original file with new content
mv "$TEMP_FILE" "$ROOT_PATH/CHANGELOG.md"
