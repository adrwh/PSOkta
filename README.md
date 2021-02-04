# PSOkta

The PSOkta PowerShell module helps administrators manage Okta Users, Authentication and SSO Applications.
## Get Started

Prerequisites: Get git and your ssh key setup.

1. `cd` into an appropriate directory on your computer to download this module.
2. `git clone git@github.com:hillsong/PSOkta.git`
3. `cd ./PSOkta/`
4. `Import-Module ./PSOkta/`

Now you have the module in your powershell session and you can use the module and its functions like any other PowerShell module.

To take a peek at the module and functions use the commands below.
1. `Get-Command -Module PSOkta`
1. `Get-Command RequestOkta`

## Examples
`Get-Okta -Endpoint users -Q 'andrew' -Verbose | select id,status,@{n='name';e={$_.profile.login}},created,lastlogin  |ft`

```
VERBOSE: GET [https://hillsong-admin.okta.com/api/v1/users?q=andrew]

id                   status name                                 created                lastLogin
--                   ------ ----                                 -------                ---------
00u5ncbaxxHXJ6JZO1t7 ACTIVE andrew.hempfling@hillsong.com        1/22/2018 1:26:10 AM   1/29/2021 2:13:45 AM
00u5ncbbhsv6hPcXO1t7 ACTIVE andrew.kahika@volunteer.hillsong.com 1/22/2018 1:26:29 AM   1/11/2021 10:01:59 PM
00u5ncbv77IVVVrKu1t7 ACTIVE tim.andrew@hillsong.com              1/22/2018 1:28:59 AM   1/27/2021 11:13:50 PM
00u5nca5k9f7VwtVz1t7 ACTIVE andrew.bishop@hillsong.com           1/22/2018 1:22:34 AM   1/20/2019 3:01:57 AM
00u7l38jkpJARZauQ1t7 ACTIVE michelle.a@hillsong.com              7/1/2018 11:15:06 PM   1/14/2021 12:49:39 AM
00ucottttmLsies3M1t7 ACTIVE rachel.andrew@volunteer.hillsong.com 12/19/2019 2:54:30 AM  
00u5ncbv0dsO14aTL1t7 ACTIVE andrew.midson@hillsong.com           1/22/2018 1:28:49 AM   1/29/2021 1:41:13 AM
00u12mmg8165pcqWD1t7 ACTIVE andrew@hillsong.com                  12/16/2016 11:16:59 PM 1/28/2021 2:59:39 AM
00u5ncbbxzbr5Uiop1t7 ACTIVE pare.andrews@hillsong.com            1/22/2018 1:26:49 AM   1/29/2021 9:11:23 AM
00u5ncbuyxrk99Unb1t7 ACTIVE andy.heuser@hillsong.com             1/22/2018 1:28:48 AM   1/14/2021 4:43:06 AM
```

## Module Development Guidelines
* Public function names must be PowerShell compliant using the "Verb-Noun" format and start with an approved Verb (https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-5.1)
* Function name Nouns should be specific and auto-documenting, auto-describing the function activity.
* Functions should do 1 thing, and do it well.
* Private/Internal functions should be named with a "util" prefix, follwed by a word/s to describe the function, such as "utilConvertDate", "utilDoSomething"
* Public functions must be advanced functions (https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.1)
* Public functions must include at least a Synopsis and one Example comment block, placed inside, at the very top of the function definition.

```
function Get-SomethingCool {
<#
 .Synopsis

 .Example
#>

param()
...
}
```

## Contribute
This module is developed and maintained by the Information Security team, contributors welcome.

If you would like to contribute, get in touch.

