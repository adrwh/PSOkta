# Setup session TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Import Config
$config = Import-PowerShellDataFile -Path ./Config.psd1

<#
 .Synopsis
  Request Okta API.

 .Description
  This function works with the Okta API to "Get" information based on the query/parameters you provide.

 .Parameter Version
  The API versoin, defaults to V1.

 .Parameter Endpoint
  The API endpoint you are querying, such as users, groups, applications.

 .Example
   # Query the user profile.
   RequestOkta -Version "v1" -Endpoint "users" -QueryString "username@hillsong.com" 

 .Example
   # Get Okta ACTIVE users.
   RequestOkta -Version "v1" -Endpoint "users" -QueryString "username@hillsong.com"

#>
function RequestOkta {
    [CmdletBinding()]
    param (
        [Parameter()]
        [String]
        $Version = "v1",
        [Parameter(Mandatory=$true)]
        [String]
        $Endpoint,
        [Parameter()]
        [String]
        $QueryString
    )

    # Setup Auth Header
$headers = @{
    Authorization = "SSWS {0}" -f $config.token
    Accept = "application/json"
    "Content-Type" = "application/json"
}

# API Resource Endpoint
$uri = "https://hillsong-admin.okta.com/api/{0}/{1}{2}" -f $Version, $Endpoint, $QueryString #?filter=status eq "ACTIVE"'

# make the API request using -FollowRelLink for automatic paging
$response = Invoke-RestMethod -Headers $headers -Uri $uri -FollowRelLink

# Unroll the pages
$data = $response| Foreach-object {$_}

return $data

}
# Choose one
# $report | Export-Csv -NoTypeInformation ./okta_all_users_report_$((get-date -Format "yyyyMMdd")).csv -Force
# $data | Export-Csv -NoTypeInformation ./okta_all_users_$((get-date -Format "yyyyMMdd")).csv -Force
