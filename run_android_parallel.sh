#!/usr/bin/env bash
# Run 4 Android sessions in parallel: 2 real devices + 2 emulators.
# Uses --testlevelsplit: each of the 4 test cases runs in its own process (own session).

set -e
if [ -z "${SAUCE_USERNAME}" ] || [ -z "${SAUCE_ACCESS_KEY}" ]; then
  echo "Error: Set SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables"
  exit 1
fi

pabot --processes 4 --testlevelsplit tests/android_device.robot tests/android_emulator.robot
