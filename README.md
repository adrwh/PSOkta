# PSOkta

The PSOkta PowerShell module helps administrators manage Okta Users, Authentication and SSO Applications.
## Get Started

Prerequisites: Get git and your ssh key setup.

1. `cd` into an appropriate directory on your computer to download this module.
2. `git clone git@github.com:hillsong/PSOkta.git`
3. `cd ./PSOkta/`
1. Createa `Config.psd1` and add the HashTable `@{token='nnnn'}`
4. `Import-Module ./PSOkta/`

Now you have the module in your powershell session and you can use the module and its functions like any other PowerShell module.

To take a peek at the module and functions use the commands below.
1. `Get-Command -Module PSOkta`
1. `Get-Command RequestOkta` 

## Contribute
This module is developed and maintained by the Information Security team, contributors welcomes.

