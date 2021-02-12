# PSOkta

```
 ██████╗░░██████╗░█████╗░██╗░░██╗████████╗░█████╗░
 ██╔══██╗██╔════╝██╔══██╗██║░██╔╝╚══██╔══╝██╔══██╗
 ██████╔╝╚█████╗░██║░░██║█████═╝░░░░██║░░░███████║
 ██╔═══╝░░╚═══██╗██║░░██║██╔═██╗░░░░██║░░░██╔══██║
 ██║░░░░░██████╔╝╚█████╔╝██║░╚██╗░░░██║░░░██║░░██║
 ╚═╝░░░░░╚═════╝░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝

 Making Okta easy..

```

The PSOkta PowerShell module helps administrators manage Oktas Universal Directory, Single Sign-On, Authentication, Multi-factor Authentication.

## Get Started

Prerequisites: 
* Get git
* Get your Okta API Token handy

1. `cd` into an appropriate directory on your computer to download this module.
2. `git clone git@github.com:hillsong/PSOkta.git`
3. `cd ./PSOkta/`
4. `Import-Module ./PSOkta`

Now you have the module in your powershell session and you can use the module and its functions like any other PowerShell module.

To take a peek at the module and functions use the commands below.
1. `Get-Command -Module PSOkta`
1. `Get-Command Get-Okta`

## Examples

Get Okta ACTIVE users.
Note: As long as you provide the Endpoint parameter values "Users, Groups or Apps" in parameter position 0, you can omit the "-Endpoint" paramter.

`Get-Okta Users -Active`

Get a single user and return the user profile.

`Get-Okta -Version "v1" -Endpoint Users -Q "username@hillsong.com"`

Get all users.
Note: The -Version paramater defaults to "v1" and can be ommitted.

`Get-Okta -Endpoint Users -All`

Get all users starting with "bob" and return some useful objects

`Get-Okta Users -Q 'bob' -Verbose | select id,status,@{n='name';e={$_.profile.login}},created,lastlogin  | ft`

## Functions

For a full list of [Functions](Functions.md) being developed

## Contribute
This module is developed and maintained by the Information Security team, contributors welcome.

If you would like to contribute, get in touch.

