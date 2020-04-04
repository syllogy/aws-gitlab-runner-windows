################################################################################
## DESCRIPTION: Setup used to configure a GitLab Runner on Windows EC2 - AWS
##              with AWS CLI, GIT and others packages.
## NAME: Get-Setup.ps1 
## AUTHOR: Lucca Pessoa da Silva Matos 
## DATE: 04.04.2020
## VERSION: 1.1
## EXEMPLE: 
##     PS C:\> .\Get-Setup.ps1
################################################################################

[CmdletBinding()]
Param(
  [Parameter(HelpMessage="AWS EC2 GitLab Runner - Setup CLI commands.")]
  [ValidateSet("all", "choco", "aws", "register", "unregister", "runners", "list", "update", "help")]
  [string]$Setup="all"
)

$AWSAccessKey="YourAWSAccessKey" # Replace with your access key
$AWSSecretKey="YourAWSSecretKey" # Replace with your secret key

$GitLabHost="YourGitLabHost" # Replace with your gitlab host
$GitLabToken="YourGitLabToken" # Replace with your gitlab token

$RunnerDescription="aws-gitlab-runner-ec2-windows" # Replace with your runner description
$RunnerTags="windows" # Replace with your runner tags

# ******************************************************************************
# FUNCTIONS
# ******************************************************************************

Function Write-Header {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "= Setup AWS EC2 GitLab Runner" -ForegroundColor Green
  Write-Host "= Chocolatey, Git, AWS CLI and GitLab Runner" -ForegroundColor Green
  Write-Host "= "
  Write-Host "= Author: Lucca Pessoa" -ForegroundColor Yellow
  Write-Host "= Date: 04-04-2020" -ForegroundColor Yellow
  Write-Host "= Version: 1.1" -ForegroundColor Yellow
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "`n"
} #End Write-Header

Function Log($MESSAGE){
  Write-Host
  Write-Host -ForegroundColor Yellow -BackgroundColor Black $MESSAGE
}#End Log

Function Get-Admin-Execution {
  # Test-Admin is not available yet, so use...
  If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -ArgumentList "-noprofile -NoExit -file `"$PSCommandPath`"" -Verb RunAs
    Exit
  }
  # From a Administrator PowerShell, if Get-ExecutionPolicy returns Restricted, run:
  If ((Get-ExecutionPolicy) -eq "Restricted") {
    Set-ExecutionPolicy Unrestricted -Force
  }
} #End Get-Admin-Execution

Function Get-Choco-Setup {
  $PACKAGES = "gitlab-runner",
  "python",
  "pip"
  Log("Installing packages...")
  foreach ($PACKAGE in $PACKAGES){
    choco install --confirm $PACKAGE
  }
  Log("Installing Git...")
  choco install git -params '"/GitAndUnixToolsOnPath"'
}#End Get-Choco-Setup

Function Get-AWSCLI-Setup {
  # Setting AWS Variables
  If ($AWSAccessKey -and $AWSSecretKey) {
    Log("AWS credentials have been defined. Setting credentials...")
    aws configure set AWS_ACCESS_KEY_ID $AWSAccessKey
    aws configure set AWS_SECRET_ACCESS_KEY $AWSSecretKey
    aws configure set default.region us-east-1
    try{
      Log("Configure AWS Profile.");
      aws configure --profile [name]
      aws s3 ls
    } 
    catch{
      Write-Error "Error - Configure AWS Profile..."
    }
  }
  Else {
    Write-Error "Error - AWS credentials not been defined. Bye Bye :)"
    Exit
  }
} #End Get-AWSCLI-Setup

Function Get-Choco-Installation {
  $URL_CHOCOLATEY = "https://chocolatey.org/install.ps1"
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  Log("Installing Choco...")
  Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($URL_CHOCOLATEY))
} #End Get-Choco-Installation

Function Get-AWSCLI-Installation {
  $AWSCLI_URL = "https://s3.amazonaws.com/aws-cli/AWSCLI64PY3.msi"
  $PATH = Join-Path C:\ (Split-Path $AWSCLI_URL -Leaf)
  Log("Installing AWSCLI .msi...")
  Invoke-WebRequest $AWSCLI_URL -OutFile $PATH
} #End Get-AWSCLI-Installation

Function Test-Choco {
  # Validate Chocolatey Environment and Path.
  try {
    If ($env:ChocolateyInstall -or (Test-Path "$env:ChocolateyInstall") -or (Get-Command choco.exe -ErrorAction SilentlyContinue)){
      Log("Chocolatey is already installed in the system.")
      Get-Choco-Setup
    }
  }
  catch {
    Log("Chocolatey ins't in the System...")
    Get-Choco-Installation
    Get-Choco-Setup
  }
} #End Test-Choco

Function Test-AWSCLI {
  If (Get-Command aws -ErrorAction SilentlyContinue){
    Log("AWSCLI is already in the system.")
    Get-AWSCLI-Setup
  }
  Else {
    Write-Error "Error - AWSCLI ins't in the System..."
    If (!(Test-Path "C:\AWSCLI64PY3.msi")){
      Get-AWSCLI-Installation
    }
    Else {
      Log("AWSCLI .msi alredy in the system...")
    }
  }
}#End Test-AWSCLI

Function Get-GitLab-Runner-Install {
  If (Get-Command gitlab-runner -ErrorAction SilentlyContinue){
    Log("Setup GitLab Runner - Status...")
    gitlab-runner status
    Log("Setup GitLab Runner - Install...")
    gitlab-runner install
  }
  Else {
    Write-Error "Error - GitLab Runner ins't in the System..."
  }
}#End Get-GitLab-Runner-Install

Function Get-GitLab-Runner-Register {
  Get-GitLab-Runner-Install
  If ($GitLabHost -and $GitLabToken) {
    try {
      Log("Setup GitLab Runner - Register...")
      gitlab-runner register -n --url $GitLabHost --registration-token $GitLabToken --description $RunnerDescription --tag-list $RunnerTags --executor shell --shell powershell --request-concurrency 15 --run-untagged false
      Log("Setup GitLab Runner - Status...")
      gitlab-runner status
      Log("Setup GitLab Runner - Stop...")
      gitlab-runner stop
      Log("Setup GitLab Runner - Start...")
      gitlab-runner start
      Log("Setup GitLab Runner - Status...")
      gitlab-runner status
    }
    catch {
      Write-Error "Error - GitLab Runner Registration"
    }
  }
  Else {
    Write-Error "Error - GitLab Runner credentials not been defined. Bye Bye :)"
    Exit
  }
}#End Get-GitLab-Runner-Register

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
    Get-GitLab-Runner-Register
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
  
  register {
    Get-GitLab-Runner-Register
  }

  unregister {
    If (Get-Command gitlab-runner -ErrorAction SilentlyContinue){
      gitlab-runner unregister --all-runners
    }
    Else {
      Write-Error "Error - GitLab Runner ins't in the System..."
    }
  }

  runners {
    If (Get-Command gitlab-runner -ErrorAction SilentlyContinue){
      gitlab-runner list
    }
    Else {
      Write-Error "Error - GitLab Runner ins't in the System..."
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
		Log("usage: all|aws|choco|register|unregister|runnnes|list|update|help")
	}
	
	default {
		Log("usage: all|aws|choco|register|unregister|runnnes|list|update|help")
  }
  
}
