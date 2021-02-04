# Setup session TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function _getToken {
  Read-Host -AsSecureString -Prompt "Please provide your Okta API Token" | Export-Clixml .token
  Write-Verbose -Verbose "Encrypting token"
}
function _getDomain {
  Read-Host -Prompt "Please provide your Okta Domain" 
}

function _getConfigFile {
  if (-not(Test-Path -Path ./Config.psd1)) {
    try {
      $ConfigFile = New-Item -ItemType File -Path ./Config.psd1
    }
    catch {
      $_.Exception
      Exit
    }
    try {
      $domain = _getDomain
      $base_uri = "'https://{0}-admin.okta.com/api/'" -f $domain
    }
    catch {
      $_.Exception
    }
    try {
      @"
@{
  token_file = '.token'
  base_uri = $base_uri
}
"@ | Add-Content -Path $ConfigFile
  
    }
    catch {
      $_.Exception
    }
  }
}

# Import Config
$config = Import-PowerShellDataFile -Path ./Config.psd1

if (-not (Test-Path -Path $config.token_file)) {
  Write-Warning -Verbose "Hold on, you don't have an API Token, standby";
  _getToken
  if (-not (Test-Path -Path $config.token_file)) {
    Write-Warning -Verbose "Still no Token file, get help, bailing."
    Exit
  }
}

function _getHeaders {
  try {
    $token = Import-Clixml $config.token_file | ConvertFrom-SecureString -AsPlainText
  }
  catch {
    
  }
  # Setup Auth Header
  return @{
    Authorization  = "SSWS {0}" -f $token
    Accept         = "application/json"
    "Content-Type" = "application/json"
  }
}

$Global:headers = _getHeaders

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
    function AddDynamicParams ($ParamName, $ParamType) {
      $Collection = New-Object -TypeName System.Collections.ObjectModel.Collection[System.Attribute]
      $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
      $ParameterAttribute.Mandatory = $false
      $Collection.Add($ParameterAttribute)
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
    # make the API request using -FollowRelLink for automatic paging

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