# Setup session TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import Config
$config = Import-PowerShellDataFile -Path ./Config.psd1

function getToken {
  Read-Host -AsSecureString -Prompt "Please provide your Okta API Token" | Export-Clixml .token
  Write-Verbose -Verbose "Encrypting token"
}

if (-not (Test-Path -Path $config.token_file)){
  Write-Warning -Verbose "Hold on, you don't have an API Token, standby";
  getToken
  if (-not (Test-Path -Path $config.token_file)) {
    Write-Warning -Verbose "Still no Token file, get help, bailing."
    Exit
  }
}

function getHeaders {
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

$Global:headers = getHeaders

function Get-Okta {
  <#
 .Synopsis
  Make requests to Okta API.

 .Example
   # Query the user profile.
   RequestOkta -Version "v1" -Endpoint "users" -Q "username@hillsong.com" 

 .Example
   # Get Okta ACTIVE users. Note: The -Version paramater defaults to "v1" and can be ommitted.
   RequestOkta -Endpoint "users" -Filter "status = 'ACTIVE'"

#>
  [CmdletBinding()]
  param (
    [Parameter()]
    [String]
    $Version = "v1",
    [Parameter(Mandatory = $true)]
    [String]
    $Endpoint,
    [Parameter()]
    [String]
    $Q,
    [Parameter()]
    [String]
    $Filter,
    [Parameter()]
    [String]
    $Search
  )

  begin {
    # Handle the parameters
    if ($Q) { $QueryString = -join ("?q=", $Q) }
    if ($Filter) { $QueryString = -join ("?filter=", $Filter) }
    if ($Search) { $QueryString = -join ("?search=", $Search) }

    # API Resource Endpoint
    $uri = -join(($config.base_uri),("/{0}/{1}{2}" -f $Version, $Endpoint, $QueryString)) #?filter=status eq "ACTIVE"'
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