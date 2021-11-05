param (
	[string]
	$userName,
	[string]
	$password,
	$sourceCrmUrl,
	$solutionList,
	$targetPath,
	$crmTimeoutMinute = 30
)

$SolutionName =$solutionList

$CRMSourceUserName=$userName

$CRMSourcePassword=$password

$CRMSourceUrl=$sourceCrmUrl

Set-StrictMode -Version latest

function InstallRequiredModule {

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

$moduleName = "Microsoft.Xrm.Data.Powershell"

$moduleVersion = "2.7.2"

if (!(Get-Module -ListAvailable -Name $moduleName )) {

Write-host "Module Not found, installing now $moduleVersion"

Install-Module -Name $moduleName -MinimumVersion $moduleVersion -Force

}

else {

Write-host "Module Found"

}

}

function EstablishCRMConnection {

param(

[string]$crmUserName,

[string]$crmSecPasswd,

[string]$crmUrl)

Write-Host "UserId: $crmUserName Password: $crmSecPasswd CrmUrl: $crmUrl"

$CRMSecPasswdString = ConvertTo-SecureString -String $crmSecPasswd -AsPlainText -Force

write-host "Creating credentials"

$Credentials = New-Object System.Management.Automation.PSCredential ($crmUserName, $CRMSecPasswdString)

write-host "Credentials object created"

write-host "Establishing crm connection next"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$crm = Get-CrmConnection -Credential $Cred

write-host "Crm connection established"

return $crm

}

#Update Source CRM instance details below:

Write-Host "going to create source connection 1"

$CrmConnection1 = EstablishCRMConnection -crmUserName "$CRMSourceUserName" -crmSecPasswd "$CRMSourcePassword" -crmUrl "$CRMSourceUrl" -Verbose

Write-Host "Source connection 1 created"

Set-CrmConnectionTimeout -conn $CrmConnection1 -TimeoutInSeconds 1000

Write-Host "going to create source connection 2"

$CrmConnection2 = EstablishCRMConnection -crmUserName "$CRMSourceUserName" -crmSecPasswd "$CRMSourcePassword" -crmUrl "$CRMSourceUrl" -Verbose

Write-Host "Source connection 2 created"

Write-Host "Exporting Solution"

Export-CrmSolution -conn $CrmConnection2 -SolutionName "$SolutionName" -SolutionFilePath "$SolutionFilePath" -SolutionZipFileName "$SolutionName.zip" -Verbose

Write-host "Solution Exported"