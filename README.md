# PSOkta

```
██████╗░░██████╗░█████╗░██╗░░██╗████████╗░█████╗░
██╔══██╗██╔════╝██╔══██╗██║░██╔╝╚══██╔══╝██╔══██╗
██████╔╝╚█████╗░██║░░██║█████═╝░░░░██║░░░███████║
██╔═══╝░░╚═══██╗██║░░██║██╔═██╗░░░░██║░░░██╔══██║
██║░░░░░██████╔╝╚█████╔╝██║░╚██╗░░░██║░░░██║░░██║
╚═╝░░░░░╚═════╝░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝
```

The PSOkta PowerShell module helps administrators manage Oktas Universal Directory, Single Sign-On, Authentication, Multi-factor Authentication.
## Get Started

Prerequisites: 
* Get git
* Get your Okta API Token handy

1. `cd` into an appropriate directory on your computer to download this module.
2. `git clone git@github.com:hillsong/PSOkta.git`
3. `cd ./PSOkta/`
4. `Import-Module ./PSOkta/`

Now you have the module in your powershell session and you can use the module and its functions like any other PowerShell module.

To take a peek at the module and functions use the commands below.
1. `Get-Command -Module PSOkta`
1. `Get-Command Get-Okta`

## Examples

Get a single user and return the user profile.

`Get-Okta -Version "v1" -Endpoint Users -Q "username@hillsong.com"`

Get all users. Note: The -Version paramater defaults to "v1" and can be ommitted.

`Get-Okta -Endpoint Users -All`

Get Okta ACTIVE users. 

`Get-Okta -Endpoint Users -Active`

Get all users starting with "bob" and return some useful objects

`Get-Okta -Endpoint Users -Q 'bob' -Verbose | select id,status,@{n='name';e={$_.profile.login}},created,lastlogin  | ft`

## Module Development Guidelines
* Public function names must be PowerShell compliant using the "Verb-Noun" format and start with an approved Verb (https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-5.1)
* Function name Nouns should be specific and auto-documenting, auto-describing the function activity.
* Functions should do 1 thing, and do it well.
* Private/Internal functions should be named with an underscore prefix, follwed by a word/s to describe the function, such as "_ConvertDate", "_DoSomething"
* Public functions must be advanced functions (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.1)
* Public functions must include at least a Synopsis, Description and one Example comment block, placed inside, at the very top of the function definition.

## Contribute
This module is developed and maintained by the Information Security team, contributors welcome.

If you would like to contribute, get in touch.

