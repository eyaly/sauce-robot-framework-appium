# Robot Framework Appium – Sauce Labs (parallel)

Robot Framework + Appium tests for **Sauce Labs**, running in parallel on:

- **Android** real device and emulator (app: `androidMobileDemoApp.apk`)
- **iOS** real device (`SauceLabs-Demo-App.ipa`) and simulator (`SauceLabs-Demo-App.Simulator.zip`)

## Framework structure

```
sauce-robot-framework-appium/
├── resources/
│   └── sauce_resource.robot    # Shared keywords and Sauce Labs connection
├── tests/
│   ├── android_device.robot    # Android on real device (parallel)
│   ├── android_emulator.robot  # Android on emulator (parallel)
│   ├── ios_device.robot        # iOS on real device (parallel)
│   └── ios_simulator.robot    # iOS on simulator (parallel)
├── requirements.txt
├── run_tests.sh               # Runs all 8 tests in parallel (pabot, test-level split)
└── README.md
```

**Layers**

- **resources/sauce_resource.robot** – Single place for Sauce Labs setup: builds the remote URL from `SAUCE_USERNAME` and `SAUCE_ACCESS_KEY`, and provides `Open Sauce Application`, `Close Sauce Application`, and `Log Test Message`. All test suites import this resource.
- **tests/** – One suite per environment. Each suite has a **Suite Setup** that opens the app on Sauce with the right capabilities (platform, device/simulator, app path). Each suite has a **Suite Teardown** that closes the session. Tests themselves are the same two cases everywhere: **Sortitem Popup Is Opened** (first) and **Selectitem** (second).

**Test cases (Android and iOS)**

| Test       | Role                                      |
|-----------|--------------------------------------------|
| Sortitem Popup Is Opened | Verifies sortitem popup is opened. |
| Selectitem              | Second test; select-item flow.     |

**Parallel execution**

- The four suites `android_device.robot`, `android_emulator.robot`, `ios_device.robot`, and `ios_simulator.robot` are run by `run_tests.sh` with **test-level split** (pabot with 8 processes). Each of the 8 test cases runs in its own process and its own Sauce session: 2 tests × 4 platforms = 8 parallel executions.

**App paths**

- Android (device + emulator): `storage:filename=androidMobileDemoApp.apk`
- iOS simulator: `storage:filename=SauceLabs-Demo-App.Simulator.zip`
- iOS real device: `storage:filename=SauceLabs-Demo-App.ipa`

## Requirements

- Python 3.8+
- Sauce Labs account

## Setup

1. **Create virtual environment and install dependencies**

   ```bash
   python3 -m venv venv
   source venv/bin/activate   # Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

2. **Set Sauce Labs credentials**

   ```bash
   export SAUCE_USERNAME=your_username
   export SAUCE_ACCESS_KEY=your_access_key
   ```

3. **Upload apps to Sauce Labs App Storage**

   - `androidMobileDemoApp.apk` – Android (device and emulator)
   - `SauceLabs-Demo-App.Simulator.zip` – iOS simulator
   - `SauceLabs-Demo-App.ipa` – iOS real device

   Use the [Sauce Labs App Storage](https://app.saucelabs.com/live/app-testing) UI or [REST API](https://docs.saucelabs.com/dev/api/storage/#upload-file-to-app-storage).

   If you see **"Unable to find file 'androidMobileDemoApp.apk' in app storage"**, the app is not in your Sauce account yet—upload it, or override the app path with `-v APP_ANDROID:storage:filename=YourActualFilename.apk` (and similarly for iOS).

## Run tests

**All 8 tests in parallel – 4 platforms, test-level split (recommended):**

```bash
./run_tests.sh
```

Or directly:

```bash
pabot --processes 8 --testlevelsplit tests/android_device.robot tests/android_emulator.robot tests/ios_device.robot tests/ios_simulator.robot
```

With `--testlevelsplit`, each of the 8 test cases runs in its own process (own Sauce session): 2 on Android device, 2 on Android emulator, 2 on iOS device, 2 on iOS simulator, all at once.

**Single suite (e.g. Android emulator only):**

```bash
robot tests/android_emulator.robot
```

**Override app path** (if your app has a different name in Sauce Storage or you use a URL):

```bash
# Single suite with your uploaded app filename
robot -v APP_ANDROID:storage:filename=MyApp.apk tests/android_emulator.robot

# Or use a public URL
robot -v APP_ANDROID:https://example.com/myapp.apk tests/android_emulator.robot

# All 8 tests with pabot (same app for all of that platform)
pabot -v APP_ANDROID:storage:filename=MyApp.apk -v APP_IOS_SIMULATOR:storage:filename=MyApp.zip -v APP_IOS_DEVICE:storage:filename=MyApp.ipa --processes 8 --testlevelsplit tests/android_device.robot tests/android_emulator.robot tests/ios_device.robot tests/ios_simulator.robot
```

## Test layout

| Suite                 | Platform | Target   | App        | Test cases   |
|----------------------|----------|----------|------------|--------------|
| `android_device.robot`  | Android  | Real device | `androidMobileDemoApp.apk`  | Sortitem Popup Is Opened, Selectitem |
| `android_emulator.robot`| Android  | Emulator    | `androidMobileDemoApp.apk`  | Sortitem Popup Is Opened, Selectitem |
| `ios_device.robot`     | iOS      | Real device | `SauceLabs-Demo-App.ipa`  | Sortitem Popup Is Opened, Selectitem |
| `ios_simulator.robot`   | iOS      | Simulator   | `SauceLabs-Demo-App.Simulator.zip`  | Sortitem Popup Is Opened, Selectitem |

- **Sortitem Popup Is Opened** – Verifies the sortitem popup opens (Android: click sort, assert "Descending order by name" visible).
- **Selectitem** – Second test; select-item flow.

Both tests only write to the log (no UI automation beyond opening the app in Suite Setup).

## Customization

- **Device / OS:** Edit the `appium:deviceName` and `appium:platformVersion` in each `tests/*.robot` Suite Setup.
- **App path:** By default apps are `storage:filename=androidMobileDemoApp.apk`, `storage:filename=SauceLabs-Demo-App.Simulator.zip`, `storage:filename=SauceLabs-Demo-App.ipa`. Replace with a URL or another `storage:filename=...` if needed.
- **Region:** Default hub is `ondemand.eu-central-1.saucelabs.com`. Change the URL in `resources/sauce_resource.robot` for other regions.
