*** Settings ***
Documentation     Capture screenshots related to cloud.upbound.io account creation.
Resource      ../resources/resources.robot

*** Test Cases ***
Capture Create Account
    Open Browser To Login Page
    Capture Sign Up    signup.png
    Capture Sign Up Form    completed_form.png
    Capture Choose Username    choose_username.png
    Capture Confirm Pin    confirm_pin.png
