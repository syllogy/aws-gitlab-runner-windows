# Test-Admin is not available yet, so use...
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-noprofile -NoExit -file `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# From a Administrator PowerShell, if Get-ExecutionPolicy returns Restricted, run:
if ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy Unrestricted -Force
}

# Validate Choco command.
$ChocoInstalled = $false
if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
  Write-Host "`n`nChocolatey command Alredy in the System."
  $ChocoInstalled = $true
} else {
  # Validate path to Install chocolatey.
  if (!(Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe')) {
    $URL_CHOCOLATEY = "https://chocolatey.org/install.ps1"
    Write-Host "`n`nInstalling Chocolatey...`n`n"
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString($URL_CHOCOLATEY))
  }else{
    Write-Host "`n`nChocolatey Alredy in the System."
  }
}

# Declaring all packages that we install.
$PACKAGES = @"
gitlab-runner
"@

# Multiline text -> array.
$PACKAGES = $PACKAGES -Split [System.Environment]::NewLine

# Trim each text package.
foreach ($PACKAGE in $PACKAGES) {
  $PACKAGE = $PACKAGE | % { $_.Trim() }
}

Write-Host "`n`nInstalling packages from Chocolatey.`n`n"

# Install pakcages
foreach ($PACKAGE in $PACKAGES) {
  choco install --confirm $PACKAGE
}

Write-Host "`n`nInstalling Git.`n`n"
choco install git -params '"/GitAndUnixToolsOnPath"'

Write-Host "`n`nUpgrading all packages from Chocolatey.`n`n"
choco upgrade all -y

Write-Host "`n`nList all installed packages.`n`n"

choco list -li

Write-Host "`n`nFinish Choco installation and configuration..."

# Validate if AWSCLI64PY3.msi alredy in the system.
if (!(Test-Path 'C:\AWSCLI64PY3.msi')) {
  $AWSCLI = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
  $PATH = Join-Path C:\ (Split-Path $AWSCLI -Leaf)
  Write-Host "`n`nInstalling AWS CLI.`n`n"
  Invoke-WebRequest $AWSCLI -OutFile $PATH
}else{
  Write-Host "`n`nThe file AWSCLI64PY3.msi Alredy in the System."
  # Validate AWS Command.
  $AwsInstalled = $false
  if (Get-Command aws -ErrorAction SilentlyContinue) {
    $AwsInstalled = $true
    Write-Host "`n`nAWS command Alredy in the System.`n`n"
    # Setting AWS Variables
    [Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "AWS_ACCESS_KEY_ID", "Machine")
    [Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "AWS_SECRET_ACCESS_KEY", "Machine")
    [Environment]::SetEnvironmentVariable("AWS_DEFAULT_REGION", "AWS_DEFAULT_REGION", "Machine")
    [Environment]::SetEnvironmentVariable("AWS_DEFAULT_OUTPUT", "AWS_DEFAULT_OUTPUT", "Machine")
    # To create a ~\.aws\credentials file run.
    # Default output format [None]: JSON (json) , Tab-delimited text (text) , ASCII-formatted table (table)
    aws configure --profile [name]
    aws s3 ls
  } else {
    Write-Host "`n`nError - AWS CLI is not in the System.`n`n"
  }
}

Write-Host "`n`nFinish AWS installation and configuration..."
