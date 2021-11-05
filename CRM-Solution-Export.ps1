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

Install-PackageProvider -Name Nuget -Force -MinimumVersion 2.8.5.201 -Scope CurrentUser
Install-Module Microsoft.Xrm.Data.Powershell -MinimumVersion 2.7.2 -Scope CurrentUser -Force


$CRMSecPasswdString = ConvertTo-SecureString -String $password -AsPlainText -Force
write-host "Creating credentials"

$Credentials = New-Object System.Management.Automation.PSCredential ($userName, $CRMSecPasswdString)
write-host "Credentials object created"
write-host "Establishing crm connection next"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$connectionString = "AuthType=ClientSecret;ClientId=$userName;ClientSecret=$password;Url=$sourceCrmUrl"
write-host $connectionString
$connection = Get-CrmConnection -ConnectionString ($connectionString) -MaxCrmConnectionTimeOutMinutes $crmTimeoutMinute


gc $solutionList |% {
    $solutionName = $_
	$packageFileNameManaged = "{0}_managed.zip" -f $solutionName,$(get-date -Format "yyyymmdd_hhss")
	$packageFileNameUnManaged = "{0}_unmanaged.zip" -f $solutionName,$(get-date -Format "yyyymmdd_hhss")

	if($targetPath -eq $null -or $targetPath -eq "") {
	  $solutionFilePath = $(Resolve-Path "./").Path
	} else {
	  New-Item $targetPath -Type Directory -Force | Out-Null
      $solutionFilePath = $targetPath
	}

	Export-CrmSolution -conn $connection -SolutionName $solutionName -SolutionFilePath $solutionFilePath -SolutionZipFileName $packageFileNameManaged -Managed 
	Export-CrmSolution -conn $connection -SolutionName $solutionName -SolutionFilePath $solutionFilePath -SolutionZipFileName $packageFileNameUnManaged

}