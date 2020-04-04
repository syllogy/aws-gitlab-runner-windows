################################################################################
## DESCRIPTION: Installation Script.
## NAME: Get-Install.ps1 
## AUTHOR: Lucca Pessoa da Silva Matos 
## DATE: 04.04.2020
## VERSION: 1.1
## EXEMPLE: 
##     PS C:\> .\Get-Install.ps1
################################################################################

# ******************************************************************************
# FUNCTIONS
# ******************************************************************************

Function Write-Header {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "= Install Setup GitLab Runner Script" -ForegroundColor Green
  Write-Host "= "
  Write-Host "= Author: Lucca Pessoa" -ForegroundColor Yellow
  Write-Host "= Date: 03-04-2020" -ForegroundColor Yellow
  Write-Host "= Version: 1.1" -ForegroundColor Yellow
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "`n"
} #End Write-Header

Function Log($MESSAGE){
  Write-Host
  Write-Host -ForegroundColor Yellow -BackgroundColor Black $MESSAGE
}#End Log

Function Get-Install {
  $SETUP_URL="https://raw.githubusercontent.com/lpmatos/aws-gitlab-runner-windows/master/Get-Setup.ps1"
  $PATH = Join-Path C:\ (Split-Path $SETUP_URL -Leaf)
  Log("Install Script...")
  Invoke-WebRequest $SETUP_URL -OutFile $PATH
}

# ******************************************************************************
# MAIN
# ******************************************************************************

Write-Header

If (!(Test-Path "C:\Get-Setup.ps1")){
  Get-Install
}
Else {
  Log("Get-Setup.ps1 alredy in the system...")
}
