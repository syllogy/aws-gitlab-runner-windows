# CHANGELOG

All important changes to this project will be added to this file! This changelog will be based on [Keep a change log](http://keepachangelog.com/)

## 1.0.0 - [ 01/04/2020 ] 

### Added

* Initial commit with basic project structure.
* Including REAMDE.md and CHANGELOG.md files in their first versions.
* Create PowerShell script to automate Chocolatey instalation with gitlab-runner and git.
* AWS configure script in PowerShell to install AWS CLI MSI.
* Adding Admin flux in PowerShell execution script.
* Validation to check if choco command and your folder exist in the system.

## 1.0.1 - [ 02/04/2020 ] 

### Added

* Create Functions to each action:
  * Write-Header()
  * Log()
  * Get-Admin-Execution()
  * Get-Choco-Setup()
  * Get-AWSCLI-Setup()
  * Get-Choco-Installation()
  * Get-AWSCLI-Installation()
  * Test-Choco()
  * Test-AWSCLI()
* Improving the script execution flow.
* Fixing some erros in Setup script.
* Adding CLI params with switch case flow. Commands:
  * all (default command)
  * choco
  * aws
  * list
  * update
  * hel
* Create install script to put Get-Setup.ps1 inside your PC.
* Try-Catch flow to choco and aws.
