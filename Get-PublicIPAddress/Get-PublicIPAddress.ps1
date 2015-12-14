<#
.SYNOPSIS
Get-PublicIPAddress.ps1 - Retrieve the public IP address of local or remote computer.

.DESCRIPTION 
This PowerShell script will retrieve the public IP address of the local computer, or
a remote computer, by querying http://checkip.dyndns.com

.OUTPUTS
Results are output to console.

.PARAMETER Computer
Specifies the remote computer that you want to connect to using PowerShell remoting
and perform the public IP address query. If this parameter is not specified then
the local computer is used.

.EXAMPLE
.\Get-PublicIPAddress.ps1
Retrieves the public IP address for the local computer.

.EXAMPLE
.\Get-PublicIPAddress.ps1 -Computer SERVER01
Retrieves the public IP address for the computer SERVER01.

.NOTES
Written by: Paul Cunningham

Find me on:

* My Blog:	http://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	http://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

Change Log
V1.00, 14/12/2015 - Initial version
#>

[CmdletBinding()]
param (
	
	[Parameter( Mandatory=$false)]
	[string]$Computer

	)

#I'm using the DynDNS tool because it returns a very plain result that is easy to parse.
$url = "http://checkip.dyndns.com"

#If a remote computer was specified then a PS remote session is used. Otherwies the web request
#is run locally.
if ($Computer)
{
    $credential = Get-Credential -Message "Enter credentials for remoting to $Computer"
    $webrequest = Invoke-Command -ComputerName $Computer -Credential $credential -ScriptBlock {Invoke-WebRequest $using:url -UseBasicParsing}
}
else
{
    
    $webrequest = Invoke-WebRequest $url -UseBasicParsing
}

#We just want the plain HTML from the web request.
$RawHtml = $webrequest.Content

#I'm using this method to parse the result because I was seeing two different results
#come back for local computers (ParsedHtml : mshtml.HTMLDocumentClass) vs
#remote computers (ParsedHtml : System.__ComObject).

$HtmlObject = New-Object -ComObject "HTMLfile"
$HtmlObject.IHTMLDocument2_Write($RawHtml)

$result = $HtmlObject.body.innerHTML

#Tidy the result so just the IP is left
$ip = $result.Split(":")[1].Trim()

#Kill a puppy with Write-Host, but you can repurpose this code to use $ip
#any way you like.
if ($Computer)
{
    Write-Host "The public IP address of computer $computer is $ip"
}
else
{
    Write-Host "The public IP address of the local computer is $ip"
}
