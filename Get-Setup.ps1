################################################################################
## DESCRIPTION: Setup used to configure a GitLab Runner on Windows EC2 - AWS.
## NAME: Get-Setup.ps1 
## AUTHOR: Lucca Pessoa da Silva Matos 
## DATE: 04.02.2020
## VERSION: 1.0
## EXEMPLE: 
##     PS C:\> .\Get-Setup.ps1
################################################################################

[CmdletBinding()]
Param(
  [Parameter(HelpMessage="AWS EC2 GitLab Runner - Setup CLI commands.")]
  [ValidateSet("all", "choco", "aws", "list", "update", "help")]
  [string]$Setup="all"
)

$AWSAccessKey="replace with your access key" # Replace with your access key
$AWSSecretKey="replace with your secret key" # Replace with your secret key

# ******************************************************************************
# FUNCTIONS
# ******************************************************************************

Function Write-Header {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "Setup AWS EC2 Gitlab Runner" -ForegroundColor Green
  Write-Host "Install Chocolatey, Git, AWS CLI and GitLab Runner" -ForegroundColor Green
  Write-Host ""
  Write-Host "Author: Lucca Pessoa" -ForegroundColor Yellow
  Write-Host "Date: 02-04-2020" -ForegroundColor Yellow
  Write-Host "Version: 0.1" -ForegroundColor Yellow
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "`n"
} #End Write-Header

Function Log($MESSAGE){
  Write-Host
  Write-Host -ForegroundColor Yellow -BackgroundColor Black $MESSAGE
}#End Log

Function Get-Admin-Execution {
  # Test-Admin is not available yet, so use...
  if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-noprofile -NoExit -file `"$PSCommandPath`"" -Verb RunAs
    Exit
  }
  # From a Administrator PowerShell, if Get-ExecutionPolicy returns Restricted, run:
  if ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy Unrestricted -Force
  }
} #End Get-Admin-Execution

Function Get-Choco-Setup {
  $PACKAGES = "gitlab-runner",
  "curl"
  Log("Installing packages...")
  foreach ($PACKAGE in $PACKAGES){
    choco install --confirm $PACKAGE
  }
  Log("Installing Git.")
  choco install git -params '"/GitAndUnixToolsOnPath"'
}#End Get-Choco-Setup

Function Get-AWSCLI-Setup {
  # Setting AWS Variables
  If ($AWSAccessKey -and $AWSSecretKey) {
    Log("AWS credentials have been defined.")
    aws configure set AWS_ACCESS_KEY_ID $AWSAccessKey
    aws configure set AWS_SECRET_ACCESS_KEY $AWSSecretKey
    aws configure set default.region us-east-1
    try{
      aws configure --profile [name]
      aws s3 ls
    } 
    catch{
      Write-Error "Error in AWS Setup credentials..."
    }
  }
  Else {
    Write-Error "AWS credentials not been defined. Bye Bye :)"
    Exit
  }
} #End Get-AWSCLI-Setup

Function Get-Choco-Installation {
  $URL_CHOCOLATEY = "https://chocolatey.org/install.ps1"
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($URL_CHOCOLATEY))
} #End Get-Choco-Installation

Function Get-AWSCLI-Installation {
  $AWSCLI_URL = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
  $PATH = Join-Path C:\ (Split-Path $AWSCLI_URL -Leaf)
  Invoke-WebRequest $AWSCLI_URL -OutFile $PATH
} #End Get-AWSCLI-Installation

Function Test-Choco {
  # Validate Chocolatey Environment and Path.
  try {
    if ($env:ChocolateyInstall -or (Test-Path "$env:ChocolateyInstall") -or (Get-Command choco.exe -ErrorAction SilentlyContinue)){
      Log("Chocolatey is already installed in the system.")
      Get-Choco-Setup
    }
  }
  catch {
    Log("Chocolatey ins't in the System... Installing Chocolatey...")
    Get-Choco-Installation
    Get-Choco-Setup
  }
} #End Test-Choco

Function Test-AWSCLI {
  if (Get-Command aws -ErrorAction SilentlyContinue){
    Log("AWSCLI is already in the system.")
    Get-AWSCLI-Setup
  }else{
    Write-Error "AWSCLI ins't in the System..."
    if(!(Test-Path "C:\AWSCLI64PY3.msi")){
      Log("Installing AWSCLI .msi...")
      Get-AWSCLI-Installation
    }else{
      Log("AWSCLI .msi alredy in the system...")
    }
  }
}#End Test-AWSCLI

# ******************************************************************************
# MAIN
# ******************************************************************************

Write-Header

Get-Admin-Execution

switch ($Setup) {
  all {
    Test-Choco
    Test-AWSCLI
    if (Get-Command aws -ErrorAction SilentlyContinue){
      Log("AWSCLI is already in the system.")
      Get-AWSCLI-Setup
    }
  }

  choco {
    Test-Choco
  }
  
	aws {
    Test-AWSCLI
    if (Get-Command aws -ErrorAction SilentlyContinue){
      Log("AWSCLI is already in the system.")
      Get-AWSCLI-Setup
    }
	}
	
	list {
    Log("List all installed packages.")
		choco list -li
	}

	update {
		Log("Upgrading all packages from Chocolatey.")
    choco upgrade all -y
  }
  
  help {
		Log("usage: all|aws|choco|list|update|help")
	}
	
	default {
		Log("usage: aws|list|update")
  }
  
}
