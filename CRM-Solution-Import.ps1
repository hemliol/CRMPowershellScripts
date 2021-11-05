param (
	[string]
	$userName,
	[string]
	$password,
	$targetCrmUrl,
	$solutionList,
	$sourcePath,
    $crmTimeoutMinute = 90
)
Install-PackageProvider -Name Nuget -Force -MinimumVersion 2.8.5.201 -Scope CurrentUser
Install-Module Microsoft.Xrm.Data.Powershell -Scope CurrentUser -Force
## Just internal stuff
$crmTimeoutSec = $crmTimeoutMinute * 60
$sourceCrmUrl = $targetCrmUrl


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

$connectionString = "AuthType=ClientSecret;ClientId=$userName;ClientSecret=$password;Url=$sourceCrmUrl"
write-host $connectionString
$connection = Get-CrmConnection -ConnectionString ($connectionString) -MaxCrmConnectionTimeOutMinutes $crmTimeoutMinute

if($solutionList -ne "" -and $solutionList -ne $null) {
gc $solutionList |% {
    $solutionName = $_
    $minimatchPackageFile = (gci $sourcePath -Filter "$($solutionName)*_managed.zip"  -Recurse  | Sort-Object Fullname -Descending | Select-Object -First 1).fullname

    if($minimatchPackageFile -eq $null){
        Write-Host "Can not find package file $_"
        exit 1
        return
    } 

    Write-Host "Importing $solutionName => $minimatchPackageFile"
    Import-CrmSolution -conn $connection -SolutionFilePath $minimatchPackageFile -MaxWaitTimeInSeconds $crmTimeoutSec
}

} else {
    if (Test-Path $sourcePath -Type Leaf ) {
        Import-CrmSolution -conn $connection -SolutionFilePath $minimatchPackageFile -MaxWaitTimeInSeconds $crmTimeoutSec
    } elseif(Test-Path $ourcePath -Type Container) {
        gci $sourcePath -Filter *.zip |% {
            Import-CrmSolution -conn $connection -SolutionFilePath $_.Fullname -MaxWaitTimeInSeconds $crmTimeoutSec
        }
    }
}
