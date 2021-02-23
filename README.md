# PSOkta

```

  ██████╗ ███████╗ ██████╗ ██╗  ██╗████████╗ █████╗ 
  ██╔══██╗██╔════╝██╔═══██╗██║ ██╔╝╚══██╔══╝██╔══██╗
  ██████╔╝███████╗██║   ██║█████╔╝    ██║   ███████║
  ██╔═══╝ ╚════██║██║   ██║██╔═██╗    ██║   ██╔══██║
  ██║     ███████║╚██████╔╝██║  ██╗   ██║   ██║  ██║
  ╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝

  Making Okta easy..

```

The PSOkta PowerShell module helps administrators manage Oktas Universal Directory, Single Sign-On, Authentication, Multi-factor Authentication.

## Module Description

The module mainly follows the Okta API schema, using the same names, labels, paths and paradigms.  For example, to do a quick search for a user or users in the API, you parse a "q" query string, likewise in the module, you pass the "q" parameter.

The module makes heavy use of "Dynamic Parameters" in attempt to minimise function count.  Some might say that breaks "coding zen", i get it, but im developing this for ease of use over tradition.

The module is written for pipeline use, ie. it outputs objects, you get stuff, then pipe it to other PSOkta functions or other native PowerShell functions.  The idea is to maintain a strong pipeline design.

## Authentication

PSOkta needs your Okta domain and Okta API Token to operate. When you run `Connect-PSOkta`, you will be asked for your Okta domain and your token.  The Token will be handled as a `Secure-String` each time you connect.

> ProTip: Save and export your token as a secure string.  This will prevent you from copy-pasting your token in each time you connect. You can use this command to get it done.
`Read-Host -AsSecureString -Prompt "Please provide your Okta API Token" | ConvertTo-SecureString | Export-CliXml $HOME/.PSOktaToken`

## Get Started

Installation has 2 options.

Option 1. 

From the PowerShell Gallery.  Use this for no fuss, you just wanna try it out.
    https://www.powershellgallery.com/packages/PSOkta/0.0.5.  This option will not necessarily be the latest code.

Option 2.

From GitHub. Use this if your familiar with GitHub, want to contribute or want the last updates/fixes.
    [https://github.com/adrwh/PSOkta]


Prerequisites: 
* Get git
* Get your Okta API Token handy

1. `cd` into an appropriate directory on your computer to download this module.
2. `git clone git@github.com:hillsong/PSOkta.git`
3. `cd ./PSOkta/`
4. `Import-Module ./PSOkta`
5. `Connect-PSOkta`
> Don't forget to connect, before trying to run commands.

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

For a full list of [Functions](Functions.md) being developed, and there will be plenty more coming.


## Contribute
This module is developed and maintained by @adrhw, contributors welcome.

If you would like to contribute, get in touch.

## License

[MIT](License.txt)

