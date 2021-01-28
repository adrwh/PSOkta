# Setup session TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import Config
$config = Import-PowerShellDataFile -Path ./Config.psd1


function Get-Okta {
  <#
 .Synopsis
  Make requests to Okta API.

 .Example
   # Query the user profile.
   RequestOkta -Version "v1" -Endpoint "users" -QueryString "username@hillsong.com" 

 .Example
   # Get Okta ACTIVE users. Note: The -Version paramater defaults to "v1" and can be ommitted.
   RequestOkta -Endpoint "users" -QueryString "status = 'ACTIVE'"

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
    $Query,
    [Parameter()]
    [Switch]
    $Q,
    [Parameter()]
    [Switch]
    $Filter,
    [Parameter()]
    [Switch]
    $Search
  )

  begin {
    # Handle the parameters
    $QueryString = $Query
    if ($Q) { $QueryString = -join ("?q=", $Query) }
    if ($Filter) { $QueryString = -join ("?filter=", $Query) }
    if ($Search) { $QueryString = -join ("?search=", $Query) }


    # Setup Auth Header
    $headers = @{
      Authorization  = "SSWS {0}" -f $config.token
      Accept         = "application/json"
      "Content-Type" = "application/json"
    }

    # API Resource Endpoint
    $uri = "https://hillsong-admin.okta.com/api/{0}/{1}{2}" -f $Version, $Endpoint, $QueryString #?filter=status eq "ACTIVE"'
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