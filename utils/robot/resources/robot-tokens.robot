*** Settings ***
Documentation     Resource file providing common methods for Upbound
Library           SeleniumLibrary
Resource          common.robot

*** Keywords ***
Create Robot Account
    [Documentation]     From the inital user page, click the Robot buttom and create a new Robot account.
    Wait Until Element Is Visible    //p[text()='Robots']
    # Click the "Robots" left-nav button
    Click Element    //p[text()='Robots']
    # Wait for the "Create Robot Account Button"
    Run Keyword And Ignore Error    Delete Robot User
    Wait Until Element Is Visible    //a[text()='Create Robot Account']
    # Skip to the create robot screen
    Click Link    //a[text()='Create Robot Account']
    Input Text    name    ExampleRobot
    Input Text    description    This is a description for an example robot token
    # Capture the form with inputs
    Capture Element Screenshot    xpath://*[@id="root"]/div[2]/main/div/div[2]    robots/robot-token-create-screen.png
    Click Button    class:css-1x2ywxm

Create Robot Token
    [Documentation]    Creates a new robot token. Assumes a robot account already exists.
    # Wait for and capture "Create your first token" div
    Wait Until Element Is Visible     //button[text()='Create Token']
    Capture Element Screenshot    class:css-16y9f05    robots/create-first-robot-token.png
    # Click "Create Token" button
    Click Button    //button[text()='Create Token']
    # Wait for the box to load and input a token name
    Wait Until Element Is Visible    name
    Input Text    name    exampletoken
    # Sleep is required to let the element fully render and not capture a partially transparent image
    Sleep    1
    Capture Element Screenshot    class:css-12yosia    robots/create-token-name.png
    # Submit the form
    Submit Form
    Wait Until Element Is Visible    //button[text()='Close']
    Capture Element Screenshot    class:css-12yosia    robots/token-credentials.png
    # Click "Close" on token creds box
    Click Element    //button[text()='Close']

Delete Robot User
    [Documentation]    Delete the first robot account. May not work with multiple robot accounts.
    # Click on the Robot Settings Tab and not the left-menu Settings
    Wait Until Element Is Visible    //h5[text()='Settings']
    Click Element    //h5[text()='Settings']
    # Click "I understand, delete this robot"
    Click Element    //button[text()='I understand, delete this robot']
    # Click "Delete Robot Account"
    Click Button     //button[text()='Delete Robot Account']
