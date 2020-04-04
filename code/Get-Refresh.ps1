################################################################################
## DESCRIPTION: Refresh Environments Script.
## NAME: Get-Refresh.ps1 
## AUTHOR: Lucca Pessoa da Silva Matos 
## DATE: 04.04.2020
## VERSION: 1.1
## EXEMPLE: 
##     PS C:\> .\Get-Refresh.ps1
################################################################################

# ******************************************************************************
# FUNCTIONS
# ******************************************************************************

Function Write-Header {
  Write-Host ""
  Write-Host "========================================" -ForegroundColor Green
  Write-Host "= Refresh Environments in PowerShell" -ForegroundColor Green
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

function Get-Refresh-Path {
  $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") +
    ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}#End Get-Refresh-Path

# ******************************************************************************
# MAIN
# ******************************************************************************

Write-Header

Log("Refresh Environment Variables in PowerShell...")

Get-Refresh-Path
