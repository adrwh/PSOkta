# Setup session TLS
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
function _getAPIToken {
  return Read-Host -AsSecureString -Prompt "Please provide your Okta API Token"
}
function _getOktaDomain {
  $Domain = Read-Host -Prompt "Please provide your Okta Domain" 
  return "https://{0}-admin.okta.com/api" -f $Domain
}

function _getAPIHeaders {
  try {
    $APIToken = (_getAPIToken | ConvertFrom-SecureString -AsPlainText)
  }
  catch {
      
  }
  # Setup Auth Header
  return @{
    Authorization  = "SSWS {0}" -f $APIToken
    Accept         = "application/json"
    "Content-Type" = "application/json"
  }
}

$Global:OktaDomain = _getOktaDomain
$Global:APIHeaders = _getAPIHeaders

Clear-Host
@'

 ██████╗░░██████╗░█████╗░██╗░░██╗████████╗░█████╗░
 ██╔══██╗██╔════╝██╔══██╗██║░██╔╝╚══██╔══╝██╔══██╗
 ██████╔╝╚█████╗░██║░░██║█████═╝░░░░██║░░░███████║
 ██╔═══╝░░╚═══██╗██║░░██║██╔═██╗░░░░██║░░░██╔══██║
 ██║░░░░░██████╔╝╚█████╔╝██║░╚██╗░░░██║░░░██║░░██║
 ╚═╝░░░░░╚═════╝░░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝

 Making Okta easy..

'@
