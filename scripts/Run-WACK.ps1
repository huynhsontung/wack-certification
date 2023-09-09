[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$reportName,

    [Parameter(Mandatory = $false)]
    [string]$packagePath,

    [Parameter(Mandatory = $false)]
    [string]$packageFullName,

    [Parameter(Mandatory = $false)]
    [string]$appType = "windowsstoreapp",

    [Parameter(Mandatory = $false)]
    [int[]]$testIds
)

# Ensure the error action preference is set to the default for PowerShell3, 'Stop'
$ErrorActionPreference = 'Stop'

if (!$packagePath -and !$packageFullName) {
    throw "At least one of packagePath or packageFullName must be specified"
}

$appcertpath = "${env:ProgramFiles(x86)}\Windows Kits\10\App Certification Kit\appcert.exe"
Write-Verbose "appcertpath = $appcertpath"

Write-Output "Reseting App certification..."
& "$appcertpath" reset

Write-Output "Initializing output directory..."
$reportoutputdirectory = "${env:GITHUB_WORKSPACE}\wack-certification"
Write-Verbose "reportoutputdirectory = $reportoutputdirectory"
New-Item -ItemType Directory -Force -Path $reportoutputdirectory | Out-Null

Write-Output "App certification is started..."
Write-Verbose "packagepath = $packagePath"
$reportoutpath = "$reportoutputdirectory\$reportName"
Write-Output "reportPath=$reportoutpath" >> $env:GITHUB_OUTPUT

$arguments = "-reportoutputpath `"$reportoutpath`" -apptype `"$appType`""
if ($packagePath) {
    $arguments += " -appxpackagepath `"$packagePath`""
} else {
    $arguments += " -packagefullname `"$packageFullName`""
}

if ($testIds.Count -gt 0) {
    $arguments += " -testid [$($testIds -join ',')]"
}

$testcommand = ".`"$appcertpath`" test $arguments"
Write-Verbose "testcommand = $testcommand"
Invoke-Expression $testcommand