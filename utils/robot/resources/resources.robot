*** Settings ***
Documentation     Resource file providing the methods to capture cloud.upbound account registration
Library           SeleniumLibrary
Library           String

*** Variables ***
${hash}
${username}
${email}

*** Keywords ***
Open Browser To Login Page
    Create a Browser
    Go To     https://cloud.upbound.io
    # Wait for the whole page to load
    Wait Until Element Is Visible    id
    # Accept Cookies
    Click Element    hs-eu-confirmation-button

Capture Sign Up
    # Continue from the Sign Up page and take a screenshot
    [Arguments]    ${img}
    Click Link    class:e19vr18b1
    Capture Element Screenshot    class:css-1pc0v7v    ${img}

Generate Email
    # Helper function to create a random string to create a docs+<string>@upbound.io email
    # Username and password for the account will also be set to <string>
    ${hash} =     Generate Random String    chars=[LETTERS]
    ${email} =     Catenate    SEPARATOR=    docs+    ${hash}    @upbound.io
    ${username} =     Catenate     SEPARATOR=    docs    ${hash}
    Set Suite Variable    ${hash}    ${hash}
    Set Suite Variable    ${email}    ${email}
    Set Suite Variable    ${username}    ${username}

Capture Sign Up Form
    # Fill out the signup form and take a screenshot.
    [Arguments]    ${img}
    Click Button     id:signup_button-email
    Input Text    firstName    A.
    Input Text    lastName    User
    Generate Email
    # Input a fake email for the screenshot
    Input Text    email    a.user@upbound.io
    Input Text    password    ${hash}
    Select Checkbox    data:testid:register-terms
    Scroll Element Into View    class:css-7fowp2
    Capture Element Screenshot    class:css-1pc0v7v    ${img}
    # Clear the fake email and put in the docs+<string>@upbound.io email
    Execute Javascript    document.querySelector('#email').value=""
    Input Text    email    ${email}
    Submit Form

Capture Choose Username
    [Arguments]    ${img}
    Wait Until Element Is Visible    username
    # Input a fake user for the screenshot
    Input Text    username    auser
    Wait Until Element Is Enabled    class:css-2zwxg9
    Capture Element Screenshot    class:css-uft8mm    ${img}
    # Clear the username and input the docs<string> username
    Execute Javascript    document.querySelector('#username').value=""
    Input Text    username    ${username}
    Submit Form
    Wait Until Element Is Visible    data:testid:pin-container

Capture Confirm Pin
    # There is no way to programatically capture the PIN value
    # so the screenshot is without the PIN completed
    [Arguments]    ${img}
    Execute Javascript    document.querySelector('.css-e51ts8').textContent= document.querySelector('.css-e51ts8').textContent.replace("${email}", "a.user@upbound.io")
    Capture Element Screenshot    class:css-1pc0v7v   ${img}

Input Login Credentials
    Input Text     username    ${username}
    Input Text     password   $password

Click Login
    Click Button    auth_button-login
    Wait Until Element Contains    class:ehhnx060    Create New Control Plane

Create a Browser
    # To make this portable we need a custom Chrome driver location
    # Also set the window size and use headless mode
    ${chrome_options} =  Evaluate  selenium.webdriver.ChromeOptions()
    Call Method    ${chrome_options}    add_argument    --binary-location\=""../venv/bin/chromedriver"
    Call Method    ${chrome_options}    add_argument    --window-size\=1700,2050
    Call Method    ${chrome_options}    add_argument    --headless
    Create WebDriver    Chrome    chrome_options=${chrome_options}
    Set Selenium Speed    0
    Set Screenshot Directory    images