#!/usr/bin/env bash
# Run all 8 tests in parallel on Sauce Labs: 4 platforms × 2 tests (test-level split).
# Platforms: Android real device, Android emulator, iOS real device, iOS simulator.
# Each of the 8 test executions gets its own Sauce session.
# Requires: SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables

set -e
if [ -z "${SAUCE_USERNAME}" ] || [ -z "${SAUCE_ACCESS_KEY}" ]; then
  echo "Error: Set SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables"
  exit 1
fi

pabot --processes 8 --testlevelsplit \
  tests/android_device.robot \
  tests/android_emulator.robot \
  tests/ios_device.robot \
  tests/ios_simulator.robot
