# Setup "module scope" variables, credit to Joel Bennett @jaykul and Mike Robbins @mikerobbins
$Script:PSOktaApiDomain = ''
$Script:PSOktaApiHeaders = ''
$Script:PSOktaApiVersion = 'v1'
$Script:PSOktaVerbose = $true

function Connect-PSOkta () {

  $Domain = Read-Host -Prompt "Please provide your Okta Domain" 
  $Script:PSOktaApiDomain = "https://{0}-admin.okta.com/api/{1}" -f $Domain, $PSOktaApiVersion

  if (Test-Path -Path (-join($HOME,'/.PSOktaToken'))) {
    $Token = Import-Clixml -Path (-join($HOME,'/.PSOktaToken')) | ConvertFrom-SecureString -AsPlainText
  } else {
    $Token = Read-Host -AsSecureString -Prompt "Please provide your Okta API Token"
  }  

  $Script:PSOktaApiHeaders = @{
    Authorization  = "SSWS {0}" -f $Token
    Accept         = "application/json"
    "Content-Type" = "application/json"
  }
}

function Get-Okta {
  <#
 .Synopsis
  Get User, Groups or Apps data from Okta.

  .Description
  This "Magic" Okta function, breaks the rules with style, by allowing you to get User, Groups and Apps data from Okta, in a single command.

  .Example
  # Get a single user and return the user profile.
  Get-Okta -Version "v1" -Endpoint Users -Q "username@hillsong.com" 

 .Example
  # Get all users. Note: The -Version paramater defaults to "v1" and can be ommitted.
  Get-Okta -Endpoint Users

 .Example
  # Get Okta ACTIVE users.
  # Note: As long as you provide the Endpoint parameter values "Users, Groups or Apps" in parameter position 0, you can omit the "-Endpoint" paramter.
  Get-Okta Users -Active

  .Example
  # Get all users starting with "bob" and return some useful objects
  Get-Okta Users -Q 'bob' -Verbose | select id,status,@{n='name';e={$_.profile.login}},created,lastlogin  | ft

#>
  [CmdletBinding()]
  Param (
    [Parameter()]
    [String]$Version = $PSOktaApiVersion,
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("Users", "Groups", "Apps")]
    [String]$Endpoint
  )

  DynamicParam {
    $ParamOptions = @{
      Users  = @(
        @{
          ParamName        = "Q"
          ParamType        = [String]
          ParamHelpMessage = "Enter an email address, first or last name to search for."
          ParamSet         = "Q"
        },
        @{
          ParamName        = "All"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return all users."
          ParamSet         = "All"
        },
        @{
          ParamName        = "Active"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return active users."
          ParamSet         = "Active"
        },
        @{
          ParamName        = "Locked"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return locked users."
          ParamSet         = "Locked"
        },
        @{
          ParamName        = "PasswordExpired"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return password expired users"
          ParamSet         = "PasswordExpired"
        },
        @{
          ParamName          = "LastUpdated"
          ParamType          = [Int]
          ParamValidateRange = "1", "90"
          ParamHelpMessage   = "Will search for users last updated {n} days ago"
          ParamSet           = "LastUpdated"
        },
        @{
          ParamName        = "Department"
          ParamType        = [String]
          ParamHelpMessage = "Enter the beginning characters or department name to search for."
          ParamSet         = "Department"
        }
      )
      Groups = @(
        @{
          ParamName          = "LastMembershipUpdated"
          ParamType          = [Int]
          ParamValidateRange = "1", "90"
          ParamHelpMessage   = "Will search for users last updated {n}d days ago"
        },
        @{
          ParamName        = "Type"
          ParamType        = [String]
          ParamValidateSet = "APP_GROUP", "BUILT_IN", "OKTA_GROUP"
          ParamHelpMessage = "Enter a group type to search for."
        }
      )
      Apps   = @(
        @{
          ParamName        = "Active"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return active users."
        },
        @{
          ParamName        = "InActive"
          ParamType        = [Switch]
          ParamHelpMessage = "Will return inactive users."
        }
      )
    }

    $RuntimeDefinedParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    function AddDynamicParams ($ParamName, $ParamType, $ParamValidateSet, $ParamHelpMessage, $ParamValidateRange, $ParamSet) {
      $Collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
      $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
      $ParameterAttribute.Mandatory = $false
      $ParameterAttribute.HelpMessage = $ParamHelpMessage
      if ($ParamSet) {
        $ParameterAttribute.ParameterSetName = $ParamSet
      }
      $Collection.Add($ParameterAttribute)
      if ($ParamValidateRange) {
        $ValidateRangeAttribute = New-Object System.Management.Automation.ValidateRangeAttribute($ParamValidateRange)
        $Collection.Add($ValidateRangeAttribute)
      }
      if ($ParamValidateSet) {
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ParamValidateSet)
        $Collection.Add($ValidateSetAttribute)
      }
      $RuntimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParamName, $ParamType, $Collection)
      $RuntimeDefinedParameterDictionary.Add($ParamName, $RuntimeDefinedParameter)
    }

    switch ($Endpoint) {
      'Users' { 
        $ParamOptions.Users.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamValidateSet $_.ParamValidateSet -ParamHelpMessage $_.ParamHelpMessage -ParamValidateRange $_.ParamValidateRange -ParamSet $_.ParamSet
        }
        Break
      }
      # Users' { 
      #   $ParamOptions.Users.foreach{
      #     AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamValidateSet $_.ParamValidateSet -ParamHelpMessage $_.ParamHelpMessage -ParamValidateRange $_.ParamValidateRange
      #   }
      #   Break
      # }
      'Groups' { 
        $ParamOptions.Groups.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamValidateSet $_.ParamValidateSet -ParamHelpMessage $_.ParamHelpMessage -ParamValidateRange $_.ParamValidateRange
        }
        Break
      }
      'Apps' { 
        $ParamOptions.Apps.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamHelpMessage $_.ParamHelpMessage
        }
        Break
      }
      Default {}
    }

    return $RuntimeDefinedParameterDictionary
  }

  begin {
    # Handle the parameters
    switch ($PSBoundParameters.Endpoint) {
      'Users' { 
        if ($PSBoundParameters.Q) { $QueryString = -join ("?q=", $PSBoundParameters.Q) }
        if ($PSBoundParameters.All) { $null = $QueryString }
        if ($PSBoundParameters.Active) { $QueryString = '?filter=status eq "ACTIVE"' }
        if ($PSBoundParameters.Locked) { $QueryString = '?filter=status eq "LOCKED_OUT"' }
        if ($PSBoundParameters.PasswordExpired) { $QueryString = '?filter=status eq "PASSWORD_EXPIRED"' }
        if ($PSBoundParameters.Department) { $QueryString = '?search=profile.department sw "{0}"' -f $PSBoundParameters.Department }
        if ($PSBoundParameters.LastUpdated) {
          $Days = $PSBoundParameters.LastUpdated
          $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-$Days).ToString('yyyy-MM-ddT00:00:00.00Z')
        }
      }
      'Groups' { 
        if ($PSBoundParameters.Type) { $QueryString = -join ('?filter=type eq "{0}"', $PSBoundParameters.Type) }
        if ($PSBoundParameters.LastMembershipUpdated) {
          $Days = $PSBoundParameters.LastMembershipUpdated
          $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-$Days).ToString('yyyy-MM-ddT00:00:00.00Z')
        }
      }
      'Apps' { 
        if ($PSBoundParameters.Active) { $QueryString = '?filter=status eq "ACTIVE"' }
        if ($PSBoundParameters.InActive) { $QueryString = '?filter=status eq "INACTIVE"' }
      }
    }
  
    $ApiParams = @{
      Uri = -join (($PSOktaApiDomain), ("/{0}{1}" -f $Endpoint.ToLower(), $QueryString))
      Method = "Get"
      FollowReLink = $true
      Verbose = $ScriptVerbose
    }

    try {
      $r = Invoke-OktaApi @ApiParams
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
      Write-Error "HttpResponseException"
    }
    catch {
      Write-Output ""
      Write-Error $_.ErrorDetails.Message | ConvertFrom-Json | Out-String
    }
  }  
  process {
    # Unroll the pages
    $r.foreach{ $_ }
  }
}

function Invoke-OktaApi {
  [CmdletBinding()]
  param (
    # Uri
    [Parameter()]
    [String]$Uri,
    # Method
    [Parameter()]
    [string]$Method,
    # FollowReLink
    [Parameter()]
    [Switch]$FollowReLink
  )
  
  begin {

    $ApiParams = @{
      Uri           = $Uri
      Method        = $Method
      Headers       = $PSOktaApiHeaders
      FollowRelLink = if ($PSBoundParameters.FollowReLink) { $true } else { $false }
      # Verbose       = $true
    }
    
  }
  
  process {
    try {
      $r = Invoke-RestMethod @ApiParams 
      return $r
    }
    catch {
      Write-Error $_.ErrorDetails.Message | ConvertFrom-Json | Out-String
    }
  }
  
  end {
    
  }
}

function Set-Okta {
  [CmdletBinding()]
  param (
    # Parameter help description
    [Parameter(ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
    [String]$Id,
    [Parameter()]
    [Switch]$Activate,
    [Parameter()]
    [Switch]$Reactivate,
    [Parameter()]
    [Switch]$Deactivate,
    [Parameter()]
    [Switch]$Suspend,
    [Parameter()]
    [Switch]$Unsuspend
  )
  
  process {

    Switch ($PSBoundParameters.Keys) {
      { "Activate", "Reactivate", "Deactivate", "Suspend", "Unsuspend" -contains $_ }
      {
        $ParamBuilder = @{
          Uri    = -join(($PSOktaApiDomain), ("/users/{0}/lifecycle/{1}" -f $PSBoundParameters.Id, $_.toLower()))
          Method = 'Post'
        }
        Break;
      }
    }

    $ApiParams = @{
      Uri     = $ParamBuilder.Uri
      Method  = $ParamBuilder.Method
    }

    Invoke-OktaApi @ApiParams
  }
}