*** Settings ***
Library    AppiumLibrary
Library    OperatingSystem
Library    Collections

*** Variables ***
${SAUCE_HUB}=    https://ondemand.eu-central-1.saucelabs.com:443/wd/hub
# Override via command line: -v APP_ANDROID:storage:filename=YourApp.apk 
${APP_ANDROID}=       storage:filename=androidMobileDemoApp.apk
${APP_IOS_SIMULATOR}=  storage:filename=SauceLabs-Demo-App.Simulator.zip
${APP_IOS_DEVICE}=     storage:filename=SauceLabs-Demo-App.ipa
# Appium version for sauce:options (each suite overrides: real device = latest, Android emulator = 2.11.0, iOS simulator = 2.11.3)
${APPIUM_VERSION}=    latest
# Which API to use when updating job status: rdc = real devices (v1/rdc/jobs), jobs = emulators/simulators (rest/v1/username/jobs)
${SAUCE_JOB_API}=    rdc
# Set to true (e.g. in ios_simulator.robot) to add sauce:options armRequired=true
${SAUCE_ARM_REQUIRED}=

*** Keywords ***
Get Sauce Remote Url
    ${username}=    Get Environment Variable    SAUCE_USERNAME
    ${access_key}=    Get Environment Variable    SAUCE_ACCESS_KEY
    RETURN    https://${username}:${access_key}@ondemand.eu-central-1.saucelabs.com:443/wd/hub

Open Sauce Application
    [Arguments]    &{capabilities}
    ${remote_url}=    Get Sauce Remote Url
    # sauce:options = Sauce Labs–specific settings. appiumVersion from ${APPIUM_VERSION} (set per suite).
    ${build}=    Get Time    format=%Y%m%d_%H%M%S
    ${sauce_options}=    Create Dictionary    appiumVersion=${APPIUM_VERSION}    build=${build}    name=${TEST_NAME}
    Run Keyword If    '${SAUCE_ARM_REQUIRED}'.lower()=='true'    Set To Dictionary    ${sauce_options}    armRequired=${True}
    Open Application    ${remote_url}    sauce:options=${sauce_options}    &{capabilities}

Close Sauce Application
    ${get_uuid_status}    ${job_uuid}=    Run Keyword And Ignore Error    Get Capability    jobUuid
    ${get_sid_status}    ${session_id}=    Run Keyword And Ignore Error    Get Appium SessionId
    # Real device (RDC) uses jobUuid; emulator/simulator (Jobs API) uses driver.session_id
    Run Keyword If    '${get_uuid_status}'=='PASS'    Log    jobUuid: ${job_uuid}    console=yes
    Run Keyword If    '${get_sid_status}'=='PASS'    Log    session_id: ${session_id}    console=yes
    ${passed}=    Set Variable If    '${TEST_STATUS}'=='PASS'    true    false
    Report Test Result To Sauce Labs
    Close Application
    # RDC API needs jobUuid; Jobs API (emulator/simulator) needs session_id
    IF    '${SAUCE_JOB_API}'.lower()=='jobs'
        Run Keyword If    '${get_sid_status}'=='PASS'    Update Sauce Job Via API    ${session_id}    ${passed}
    ELSE
        Run Keyword If    '${get_uuid_status}'=='PASS'    Update Sauce Job Via API    ${job_uuid}    ${passed}
    END

Report Test Result To Sauce Labs
    # Try in-session update (works when Sauce accepts executeScript from Appium)
    IF    '${TEST_STATUS}'=='PASS'
        Run Keyword And Ignore Error    Execute Script    sauce:job-result=passed
    ELSE
        Run Keyword And Ignore Error    Execute Script    sauce:job-result=failed
        Run Keyword And Ignore Error    Execute Script    sauce:context=${TEST_MESSAGE}
    END

Update Sauce Job Via API
    [Arguments]    ${job_id}    ${passed}
    ${username}=    Get Environment Variable    SAUCE_USERNAME
    ${access_key}=    Get Environment Variable    SAUCE_ACCESS_KEY
    IF    '${SAUCE_JOB_API}'.lower()=='jobs'
        # Jobs API for emulators/simulators: https://docs.saucelabs.com/dev/api/jobs/#update-a-job
        ${api_url}=    Set Variable    https://api.eu-central-1.saucelabs.com/rest/v1/${username}/jobs/${job_id}
    ELSE
        # RDC API for real devices: https://docs.saucelabs.com/dev/api/rdc/#update-a-job
        ${api_url}=    Set Variable    https://api.eu-central-1.saucelabs.com/v1/rdc/jobs/${job_id}
    END
    Log    Updating Sauce job_id=${job_id} passed=${passed} (API: ${SAUCE_JOB_API})    console=yes
    Run    curl -s -X PUT -u ${username}:${access_key} -H "Content-Type: application/json" -d '{"passed": ${passed}}' ${api_url}

Log Test Message
    [Arguments]    ${message}
    Log    ${message}    console=yes
