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
        },
        @{
          ParamName = "All"
          ParamType = [Switch]
        },
        @{
          ParamName = "Active"
          ParamType = [Switch]
        },
        @{
          ParamName = "Locked"
          ParamType = [Switch]
        },
        @{
          ParamName = "PasswordExpired"
          ParamType = [Switch]
        },
        @{
          ParamName = "LastUpdated"
          ParamType = [String]
          ParamValidateSet = "1d","3d","5d","7d","15d","30d","60d","90d"
        },
        @{
          ParamName = "Department"
          ParamType = [String]
        }
      )
      Groups = @(
        @{
          ParamName = "LastMembershipUpdated"
          ParamType = [String]
        },
        @{
          ParamName = "Type"
          ParamType = [String]
        }
      )
      Apps   = @(
        @{
          ParamName = "Active"
          ParamType = [Switch]
        }
      )
    }

    $RuntimeDefinedParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
    function AddDynamicParams ($ParamName, $ParamType, $ParamValidateSet) {
      $Collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
      $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
      $ParameterAttribute.Mandatory = $false
      if ($ParamValidateSet){
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($ParamValidateSet)
      }
      $Collection.Add($ParameterAttribute)
      $Collection.Add($ValidateSetAttribute)
      $RuntimeDefinedParameter = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameter($ParamName, $ParamType, $Collection)
      $RuntimeDefinedParameterDictionary.Add($_.ParamName, $RuntimeDefinedParameter)
    }

    switch ($Endpoint) {
      'Users' { 
        $ParamOptions.Users.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType
        }
        Break
      }
      'Groups' { 
        $ParamOptions.Groups.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType
        }
        Break
      }
      'Apps' { 
        $ParamOptions.Apps.foreach{
          AddDynamicParams -ParamName $_.ParamName -ParamType $_.ParamType
        }
        Break
      }
      Default {}
    }

    return $RuntimeDefinedParameterDictionary
  }

  begin {
    # Handle the parameters
    if ($PSBoundParameters.Q) { $QueryString = -join ("?q=", $PSBoundParameters.Q) }
    if ($PSBoundParameters.All) { $null = $QueryString }
    if ($PSBoundParameters.Active) { $QueryString = '?filter=status eq "ACTIVE"' }
    if ($PSBoundParameters.Locked) { $QueryString = '?filter=status eq "LOCKED_OUT"' }
    if ($PSBoundParameters.PasswordExpired) { $QueryString = '?filter=status eq "PASSWORD_EXPIRED"' }
    if ($PSBoundParameters.Department) { $QueryString = '?search=profile.department sw "{0}"' -f $PSBoundParameters.Department }
    if ($PSBoundParameters.LastUpdated) {
      switch ($PSBoundParameters.LastUpdated) {
        "1d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-1).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "3d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-3).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "5d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-5).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "7d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-7).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "15d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-15).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "30d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-30).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "60d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-60).ToString('yyyy-MM-ddT00:00:00.00Z') }
        "90d" { $QueryString = '?filter=lastUpdated gt "{0}"' -f (Get-Date).AddDays(-90).ToString('yyyy-MM-ddT00:00:00.00Z') }
        Default {}
      }
      
      # $QueryString = '?filter=lastUpdated gt "{0}"' -f $PSBoundParameters.LastUpdated 
    
    }



    # API Resource Endpoint
    $uri = -join (($config.base_uri), ("/{0}/{1}{2}" -f $Version, $Endpoint.ToLower(), $QueryString)) #?filter=status eq "ACTIVE"'
    Write-Verbose "GET [$uri]"

    try {
      $response = Invoke-RestMethod -Headers $headers -Uri $uri -FollowRelLink -Verbose:$false
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
      Write-Output "HTTP Error"
    }
    catch {
      $_
    }
  }  
  process {
    # Unroll the pages
    $data = $response | Foreach-object { $_ }

    return $data
  }
  

}
# Choose one
# $report | Export-Csv -NoTypeInformation ./okta_all_users_report_$((get-date -Format "yyyyMMdd")).csv -Force
# $data | Export-Csv -NoTypeInformation ./okta_all_users_$((get-date -Format "yyyyMMdd")).csv -Force

# Add public functions (only) here
$functions = @(
  "Get-Okta"
)
 
Export-ModuleMember -Function $functions