@ECHO OFF

SET CurrentDir=%~dp0

PowerShell %CurrentDir%Get-HAPowerUsage.ps1
