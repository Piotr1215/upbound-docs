*** Settings ***
Documentation     Capture screenshots related to generating robot tokens
Resource      ../resources/common.robot
Resource      ../resources/orgainzation.robot
Resource      ../resources/robot-tokens.robot

*** Test Cases ***
Create Organization
    [Documentation]    Login as a user with no organization and capture the workflow to create one.
    Login to Upbound    %{UP_NO_ORG_USERNAME}    %{UP_NO_ORG_PASSWORD}
    Capture Create Organization
    [Teardown]    Close All Browsers

Get Org Menu
    [Documentation]    Login as a user with organizations and capture menu screenshots.
    Login to Upbound    %{UP_ORG_USERNAME}    %{UP_ORG_PASSWORD}
    Capture Organization Left Menu

Capture Robot Token
    [Documentation]    Capture the flow of creating a new robot token. Assumes a browser is created and the user is logged in.
    Create Robot Account
    Create Robot Token
    Delete Robot User
    [Teardown]    Close All Browsers