*** Settings ***
Resource    ../resources/sauce_resource.robot
Test Setup     Open Sauce Application    platformName=Android    browserName=    appium:automationName=UiAutomator2    appium:app=${APP_ANDROID}    appium:deviceName=Samsung.*    appium:platformVersion=16
Test Teardown  Close Sauce Application

*** Variables ***
${APPIUM_VERSION}=    latest

*** Test Cases ***
Sortitem Popup Is Opened
    Click Element    accessibility_id=Shows current sorting order and displays available sorting options
    Wait Until Element Is Visible    accessibility_id=Descending order by name    timeout=5s
    Log Test Message    Sortitem popup is opened (real device)
    Sleep    5s

Selectitem

    Click Element    xpath=(//android.widget.ImageView[@content-desc="Product Image"])[1]
    Wait Until Element Is Visible    accessibility_id=Displays selected product    timeout=5s
    Log Test Message    Selectitem completed (real device): selected product displayed
    Sleep    5s
