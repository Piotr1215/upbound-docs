---
title: "Robot Accounts"
weight: 10
---

Robot accounts provide a method to authenticate to Upbound without the ability to use the Upbound Cloud interface or create new resources. Robot accounts use API tokens and don't have passwords.

Automation systems like CI/CD and official providers use robot tokens for authentication to Upbound.

## Robot account and token creation steps
To create a robot account and robot token in the Upbound Universal Console:
1. Select the organization from the account menu.
2. Select **Admin Console**.
3. Select **Robots** from the left-hand navigation. 
4. Select **Create Robot Account**.
5. Provide a **Name** and optional description.
6. Select **Create Robot**.
7. Select **Create Token**.
8. Provide a **Name** for the token.

## Creating a robot account
Select the icon in the bottom left to access the user menu. 

<!-- TODO: Create a carousel of these instructions -->
<img src="/images/accounts/account-menu-admin-console.png" alt="Organization Admin Console menu" caption="" />   

Select the organization name and Admin Console.

{{< hint type="important" >}}
Only organizations can have robot accounts. Personal accounts can't create robot accounts.
{{< /hint >}}  

<img src="/images/accounts/left-menu-organization.png" alt="Left-hand menu with Robots option" /> 

The organization administrator console provides more options in the left-hand menu including _Robots_.

<img src="/images/accounts/create-robot-account.png" alt="Robots landing page" />

Select the _Create Robot Account_ button.

<img src="/images/accounts/robot-account-create-screen.png" alt="Provide a name and description for the robot account" />

Provide a name for the robot account and optional description. Select _Create Robot Account_

## Creating a robot token
Robot tokens belong to specific robot accounts. From the robot account 

<img src="/images/robots/create-first-robot-token.png" alt="Create Token button" />

From a robot account select the _Create Token_ button. 

<img src="/images/robots/create-token-name.png" alt="Provide a name for the robot token" />

Provide a name for the robot token and select _Create Token_.

The next screen shows the `Access ID` and `Token` values. These values are the "username" and "password" equivalents for the new token. 

{{< hint type="warning" >}}
The `Token` is unrecoverable after this screen.
{{< /hint >}}

<img src="/images/robots/token-credentials.png" alt="Example token credentials" />