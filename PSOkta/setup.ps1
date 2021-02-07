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
  
if (-not(Test-Path -Path ./Config.psd1)) {
  _getConfigFile  
}

# Import Config
$config = Import-PowerShellDataFile -Path ./Config.psd1
  
if (-not (Test-Path -Path $config.token_file)) {
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
Write-Output "Ok, ready to rumble, start using the module.  Type this to get started 'Get-Command -Module PSOkta"
Get-Command -Module PSOkta