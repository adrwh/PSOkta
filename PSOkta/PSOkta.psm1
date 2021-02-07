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
  Get-Okta -Endpoint Users -Active

  .Example
  # Get all users starting with "bob" and return some useful objects
  Get-Okta -Endpoint Users -Q 'bob' -Verbose | select id,status,@{n='name';e={$_.profile.login}},created,lastlogin  | ft

#>
  [CmdletBinding()]
  Param (
    [Parameter()]
    [String]$Version = "v1",
    [Parameter(Mandatory = $true, Position = 0)]
    [ValidateSet("Users", "Groups", "Apps")]
    [String]$Endpoint
  )

  DynamicParam {
    $ParamOptions = @{
      Users  = @(
        @{
          ParamName = "Q"
          ParamType = [String]
          ParamHelpMessage = "Enter an email address, first or last name to search for."
        },
        @{
          ParamName = "All"
          ParamType = [Switch]
          ParamHelpMessage = "Will return all users."
        },
        @{
          ParamName = "Active"
          ParamType = [Switch]
          ParamHelpMessage = "Will return active users."
        },
        @{
          ParamName = "Locked"
          ParamType = [Switch]
          ParamHelpMessage = "Will return locked users."
        },
        @{
          ParamName = "PasswordExpired"
          ParamType = [Switch]
          ParamHelpMessage = "Will return password expired users"
        },
        @{
          ParamName        = "LastUpdated"
          ParamType        = [Int]
          ParamValidateRange = "1", "90"
          ParamHelpMessage = "Will search for users last updated {n} days ago"
        },
        @{
          ParamName = "Department"
          ParamType = [String]
          ParamHelpMessage = "Enter the beginning characters or department name to search for."
        }
      )
      Groups = @(
        @{
          ParamName = "LastMembershipUpdated"
          ParamType = [Int]
          ParamValidateRange = "1", "90"
          ParamHelpMessage = "Will search for users last updated {n}d days ago"
        },
        @{
          ParamName = "Type"
          ParamType = [String]
          ParamValidateSet = "APP_GROUP", "BUILT_IN", "OKTA_GROUP"
          ParamHelpMessage = "Enter a group type to search for."
        }
      )
      Apps   = @(
        @{
          ParamName = "Active"
          ParamType = [Switch]
          ParamHelpMessage = "Will return active users."
        },
        @{
          ParamName = "InActive"
          ParamType = [Switch]
          ParamHelpMessage = "Will return inactive users."
        }
      )
    }

    $RuntimeDefinedParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    function AddDynamicParams ($ParamName, $ParamType, $ParamValidateSet, $ParamHelpMessage, $ParamValidateRange) {
      $Collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
      $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
      $ParameterAttribute.Mandatory = $false
      $ParameterAttribute.HelpMessage = $ParamHelpMessage
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
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType -ParamValidateSet $_.ParamValidateSet -ParamHelpMessage $_.ParamHelpMessage -ParamValidateRange $_.ParamValidateRange
        }
        Break
      }
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
  
  # API Resource Endpoint
  $uri = -join (($config.base_uri), ("/{0}/{1}{2}" -f $Version, $Endpoint.ToLower(), $QueryString))
  Write-Verbose "GET [$uri]"

  try {
    $response = Invoke-RestMethod -Headers $headers -Uri $uri -FollowRelLink -Verbose:$false
  }
  catch [Microsoft.PowerShell.Commands.HttpResponseException] {
    Write-Error "HttpResponseException"
  }
  catch {
    $_
  }
}  
process {
  # Unroll the pages
  $response | Foreach-object { $_ }
}
}