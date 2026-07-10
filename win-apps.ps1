<#
.SYNOPSIS
Name : setup-apps.ps1

.DESCRIPTION
Description : Incremental backup naar USB-disk v2.0 (c) HC 2004-2025 ...

.NOTES
Author	: H. Celik
Version	: 1.1
Date	: 16-01-2016,10-07-2026 H. Celik

set-executionpolicy -executionpolicy ByPass
#>

function Install-Winget {
    param(
        [Parameter(Mandatory)]
        [string]$PackageId,

        [switch]$ask
    )

    if ($ask) {
        $choice = Read-Host "`nInstall ${PackageId}? (y/N)"

        if ($choice.ToLower() -ne "y") {
            Write-Host "User skipped installation $PackageId." -ForegroundColor Yellow
            return
        }
    }

    Write-Host "Installing $PackageId..." -ForegroundColor Cyan

    winget install `
        --id $PackageId `
        -e `
        --silent `
        --accept-package-agreements `
        --accept-source-agreements
}

# Window Title
$host.UI.RawUI.WindowTitle = "install apps"

New-Item -ItemType Directory -Force "$env:USERPROFILE\data" | Out-Null
New-Item -ItemType Directory -Force "C:\temp" | Out-Null

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Windows Application Installer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install multiple applications" -ForegroundColor Yellow
Write-Host "and modify settings on this computer." -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Continue with the installation? (y/N)"

if ($choice.ToLower() -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "Winget is not installed." -ForegroundColor Red
    pause
    exit
}

# CPU architecture
$architecture = (Get-CimInstance Win32_Processor).AddressWidth

If ($architecture -eq 64) {
	# Microsoft Store install 
	# winget search kate | winget install --id KDE.Kate
	# winget upgrade --all | winget show KDE.Kate
	
	# Utillitie
	Install-Winget 9N6GL0BVKPHN -ask 	#Authenticator 2FA

	# Programming languages
	Install-Winget JetBrains.PyCharm -ask
	Install-Winget GoLang.Go -ask
	Install-Winget alexx2000.DoubleCommander -ask
	Install-Winget Python.Python.3.14
	
	# Tools
	Install-Winget Ghisler.TotalCommander
	Install-Winget 7zip.7zip

	# Editors
	Install-Winget KDE.Kate
	Install-Winget 9NKSQGP7F2NH #WhatsApp
	Install-Winget SublimeHQ.SublimeText.4
	Install-Winget Notepad++.Notepad++
	Install-Winget Microsoft.VisualStudioCode

	# Brouwser
	Install-Winget Brave.Brave
	Install-Winget Mozilla.Firefox
	Install-Winget Google.Chrome

	# reload path
	$env:Path =
	    [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
	    [System.Environment]::GetEnvironmentVariable("Path", "User")
	
	# Python Launcher (pip.exe):
	$python = Get-Command python -ErrorAction SilentlyContinue

	if ($python -and $python.Source -notlike "*WindowsApps*") {
	    & $python.Source -m pip install --upgrade pip
	    & $python.Source -m pip install WMI pywin32 colorama
	} else {
	    Write-Host "Real Python installation not found." -ForegroundColor Yellow
	}
} 

pause

