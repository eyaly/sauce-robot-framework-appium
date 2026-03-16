*** Settings ***
Resource    ../resources/sauce_resource.robot
Test Setup     Open Sauce Application    platformName=iOS    browserName=    appium:automationName=XCUITest    appium:app=${APP_IOS_DEVICE}    appium:deviceName=iPhone.*    appium:platformVersion=18
Test Teardown  Close Sauce Application

*** Variables ***
${APPIUM_VERSION}=    latest

*** Test Cases ***
Sortitem Popup Is Opened
    Click Element    chain=**/XCUIElementTypeButton[`name == "Button"`]
    Wait Until Element Is Visible    chain=**/XCUIElementTypeStaticText[`name == "Name - Ascending"`]    timeout=5s

Selectitem
    Click Element    chain=**/XCUIElementTypeImage[`name == "Product Image"`][1]
    Wait Until Element Is Visible    accessibility_id=BagBlack Image    timeout=5s
