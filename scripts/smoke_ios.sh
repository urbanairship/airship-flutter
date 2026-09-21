#!/bin/bash
# Boots a simulator, launches the example app, and fails if either the process
# died or takeOff reported an error.
#
# A build cannot catch either. iOS 27 terminates apps built against its SDK
# that have not adopted the UIScene lifecycle, at scene creation, before any
# Dart code runs. And a takeOff that throws - EUCUST-160 - leaves the app
# running and rendering. `flutter build` stays green through both.

set -o pipefail
set -e

ROOT_PATH="$(cd "$(dirname "${0}")/.." && pwd)"
APP_PATH="$ROOT_PATH/example/build/ios/iphonesimulator/Runner.app"
BUNDLE_ID="com.urbanairship.richpush"
SETTLE_SECONDS="${SMOKE_SETTLE_SECONDS:-15}"
CREATED_DEVICE=""

if [ ! -d "$APP_PATH" ]; then
  echo "No simulator build found at $APP_PATH" 1>&2
  exit 1
fi

LOG_FILE="$(mktemp -t airship-flutter-smoke)"
STREAM_PID=""

cleanup() {
  if [ -n "$STREAM_PID" ]; then
    kill "$STREAM_PID" > /dev/null 2>&1 || true
  fi
  rm -f "$LOG_FILE"
  if [ -n "$CREATED_DEVICE" ]; then
    xcrun simctl shutdown "$CREATED_DEVICE" > /dev/null 2>&1 || true
    xcrun simctl delete "$CREATED_DEVICE" > /dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

# Anchor to the active Xcode's own SDK rather than the newest runtime
# installed, so the smoke test matches what the build targeted.
SDK_VERSION=$(xcrun --sdk iphonesimulator --show-sdk-version)
RUNTIME_ID=$(xcrun simctl list runtimes available -j | jq -r --arg sdk "$SDK_VERSION" '
  [.runtimes[] | select(.platform == "iOS")] as $runtimes
  | ($runtimes | map(select(.version == $sdk)) | first.identifier) //
    ($runtimes | sort_by(.version | split(".") | map(tonumber)) | last.identifier)
')

if [ -z "$RUNTIME_ID" ] || [ "$RUNTIME_ID" == "null" ]; then
  echo "No available iOS Simulator runtime found." 1>&2
  exit 1
fi

UDID=$(xcrun simctl list devices available -j | jq -r --arg runtime "$RUNTIME_ID" '
  [.devices[$runtime][]? | select(.name | test("^iPhone"))] | first.udid // empty
')

if [ -z "$UDID" ]; then
  # Ask the runtime which devices it supports - the global device type list
  # includes models this runtime cannot create.
  DEVICE_TYPE=$(xcrun simctl list runtimes -j | jq -r --arg rt "$RUNTIME_ID" '
    [.runtimes[] | select(.identifier == $rt)] | first
    | [.supportedDeviceTypes[]? | select(.name | test("^iPhone"))] | last.identifier // empty
  ')

  if [ -z "$DEVICE_TYPE" ]; then
    echo "No iPhone device type available for runtime $RUNTIME_ID." 1>&2
    exit 1
  fi

  UDID=$(xcrun simctl create "airship-flutter-smoke" "$DEVICE_TYPE" "$RUNTIME_ID")
  CREATED_DEVICE="$UDID"
fi

xcrun simctl boot "$UDID" > /dev/null 2>&1 || true
xcrun simctl bootstatus "$UDID" -b > /dev/null

xcrun simctl uninstall "$UDID" "$BUNDLE_ID" > /dev/null 2>&1 || true
xcrun simctl install "$UDID" "$APP_PATH"

echo -ne "\n\n *********** LAUNCHING $BUNDLE_ID *********** \n\n"

# Stream the log rather than querying it afterwards: entries reach the
# queryable archive on their own schedule, so a `log show` seconds after
# launch can miss lines that are plainly there a minute later.
xcrun simctl spawn "$UDID" log stream --predicate 'process == "Runner"' \
  --style compact > "$LOG_FILE" 2>/dev/null &
STREAM_PID=$!
sleep 3

if ! LAUNCH_OUTPUT=$(xcrun simctl launch "$UDID" "$BUNDLE_ID" 2>&1); then
  echo "App failed to launch: $LAUNCH_OUTPUT" 1>&2
  exit 1
fi

PID=$(echo "$LAUNCH_OUTPUT" | awk -F': ' '{print $2}')

sleep "$SETTLE_SECONDS"

kill "$STREAM_PID" > /dev/null 2>&1 || true
STREAM_PID=""

dump_log() {
  tail -40 "$LOG_FILE" 1>&2
}

# Simulator apps are host processes, so the host can poll the returned pid.
if ! kill -0 "$PID" 2>/dev/null; then
  echo "App exited within ${SETTLE_SECONDS}s of launch." 1>&2
  dump_log
  exit 1
fi

# No captured output means the takeOff check below would pass by default.
if [ ! -s "$LOG_FILE" ]; then
  echo "Captured no device log; cannot verify takeOff." 1>&2
  exit 1
fi

# A live process is not enough. A takeOff that throws leaves the app running
# and rendering - which is exactly how EUCUST-160 reached a customer - so fail
# on that too. The example ships placeholder credentials, so takeOff not
# *succeeding* is expected here; takeOff *erroring* is not.
if grep -qE "Method: takeOff|Invalid JSON" "$LOG_FILE"; then
  echo "takeOff reported an error during launch." 1>&2
  dump_log
  exit 1
fi

echo "App still running after ${SETTLE_SECONDS}s (pid $PID), takeOff reported no error."
xcrun simctl terminate "$UDID" "$BUNDLE_ID" > /dev/null 2>&1 || true
exit 0
