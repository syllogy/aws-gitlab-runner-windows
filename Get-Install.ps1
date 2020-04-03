################################################################################
## DESCRIPTION: Installation Script.
## NAME: Get-Install.ps1 
## AUTHOR: Lucca Pessoa da Silva Matos 
## DATE: 04.02.2020
## VERSION: 1.0
## EXEMPLE: 
##     PS C:\> .\Get-Install.ps1
################################################################################

$SETUP_URL="https://raw.githubusercontent.com/lpmatos/aws-gitlab-runner-windows/master/setup.ps1"
$PATH = Join-Path C:\ (Split-Path $SETUP_URL -Leaf)
Invoke-WebRequest $SETUP_URL -OutFile $PATH
