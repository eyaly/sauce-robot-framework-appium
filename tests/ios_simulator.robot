*** Settings ***
Resource    ../resources/sauce_resource.robot
Test Setup     Open Sauce Application    platformName=iOS    browserName=    appium:automationName=XCUITest    appium:app=${APP_IOS_SIMULATOR}    appium:deviceName=iPhone Simulator    appium:platformVersion=26.1
Test Teardown  Close Sauce Application

*** Variables ***
${APPIUM_VERSION}=    2.19.0
${SAUCE_JOB_API}=     jobs
${SAUCE_ARM_REQUIRED}=    true

*** Test Cases ***
Sortitem Popup Is Opened
    Click Element    chain=**/XCUIElementTypeButton[`name == "Button"`]
    Wait Until Element Is Visible    chain=**/XCUIElementTypeStaticText[`name == "Name - Ascending"`]    timeout=5s

Selectitem
    Click Element    chain=**/XCUIElementTypeImage[`name == "Product Image"`][1]
    Wait Until Element Is Visible    accessibility_id=BagBlack Image    timeout=5s
