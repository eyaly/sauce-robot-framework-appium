#!/usr/bin/env bash
# Run android_device.robot with 2 test cases in parallel on 2 real devices.
# Uses pabot --testlevelsplit: each test runs in its own process, each runs Suite Setup = 2 Sauce sessions = 2 devices.

set -e
if [ -z "${SAUCE_USERNAME}" ] || [ -z "${SAUCE_ACCESS_KEY}" ]; then
  echo "Error: Set SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables"
  exit 1
fi

pabot --processes 2 --testlevelsplit tests/android_device.robot
