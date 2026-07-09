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
set-executionpolicy -executionpolicy remotesigned
set-executionpolicy -executionpolicy Unrestricted
#>


function Choice-Install {
    param(
        [string]$Name,
        [string]$FullPath,
        [string[]]$Arguments
    )

    Write-Host -NoNewline "`nInstall '$Name'? (y/n) " -ForegroundColor DarkGreen
    $choice = Read-Host

    if ($choice -ne 'y') {
        Write-Host "Installation canceled." -ForegroundColor Yellow
        return
    }

    if (!(Test-Path $FullPath)) {
        Write-Host "File not found: $FullPath" -ForegroundColor Red
        return
    }

    Write-Host "App : $Name"
    Write-Host "File: $FullPath"
    Write-Host "Args: $($Arguments -join ' ')"

    Start-Process `
        -FilePath $FullPath `
        -ArgumentList $Arguments `
        -Wait
}

function Find-InstallDisk {

    $drives = Get-Volume | Where-Object { $_.DriveLetter }

    foreach ($disk in $drives) {
        $setupPath = Join-Path "$($disk.DriveLetter):\" "setup\programs\KMS"

        if (Test-Path $setupPath) {
            Write-Host "`nInstallation drive found: $($disk.DriveLetter): ($($disk.FileSystemLabel))" -ForegroundColor Green
            return "$($disk.DriveLetter):"

        } else {

            Write-Host "Not an installation disk: $($disk.DriveLetter): ($($disk.FileSystemLabel))" -ForegroundColor Yellow
        }
    }

    Write-Host "Installation disk not found." -ForegroundColor Red
    return $null
}


function Install-Winget {
    param([string]$Id)

    winget install `
        --id $Id `
        -e `
        --accept-package-agreements `
        --accept-source-agreements
}

<# function Install-Winget {
    param([string]$Id)

    winget uninstall `
        --id $Id
} #>

# Window Title
$host.UI.RawUI.WindowTitle = "install apps"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host " Windows Application Installer" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This script will install multiple applications" -ForegroundColor Yellow
Write-Host "and modify settings on this computer." -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Continue with the installation? (y/n)"

if ($choice.ToLower() -ne 'y') {
    Write-Host "Operation cancelled." -ForegroundColor Red
    exit
}

# Variables
$FullScriptpath = $MyInvocation.MyCommand.Path
$Scriptpath = Split-Path $FullScriptpath

New-Item -ItemType Directory -Force "$env:USERPROFILE\data" | Out-Null
New-Item -ItemType Directory -Force "C:\temp" | Out-Null

$DriveLetter = Find-InstallDisk
if (-not $DriveLetter) {
    pause
    exit
}

# CPU architecture
$architecture = (Get-CimInstance Win32_Processor).AddressWidth

If ($architecture -eq 64) {

	# registry
	$choice = Read-Host -Prompt "`nWil U sublime & VSCode registry installeren? (y/n)" 
	if ($choice -eq 'y') {
		Write-Host "Import register files ..."
		reg import "$DriveLetter/setup/registry/edit-with_sublime.reg"
		reg import "$DriveLetter/setup/registry/open-here_sublime.reg"
		reg import "$DriveLetter/setup/registry/edit-with_VSCode.reg"
		reg import "$DriveLetter/setup/registry/open-here_VSCode.reg"
		reg import "$DriveLetter/setup/registry/synchronize_time_dual_booting_hackintosh_and_windows.reg"
	}

	# Microsoft Store install ( winget search kate )

	# Tools
	Install-Winget Ghisler.TotalCommander
	Install-Winget alexx2000.DoubleCommander
	Install-Winget 7zip.7zip

	# Editors
	Install-Winget KDE.Kate
	Install-Winget WhatsApp.WhatsApp
	Install-Winget SublimeHQ.SublimeText.4
	Install-Winget Notepad++.Notepad++
	Install-Winget Microsoft.VisualStudioCode

	# Brouwser
	Install-Winget Brave.Brave
	Install-Winget Mozilla.Firefox
	Install-Winget Google.Chrome
	
	# Programming languages
	Install-Winget Python.Python.3.14
	#Install-Winget JetBrains.PyCharm
	#Install-Winget GoLang.Go

	# Utillitie
	# winget search authenticator | winget upgrade --all
	# winget install --id 9N6GL0BVKPHN #FirstOrder Authenticator 2FA
	
	$choice = Read-Host -Prompt "`nWilt U Totaal Commander, SFTP and key installeren? (y/n)"
	if ($choice -eq 'y') {		
		&"C:/Program Files/7-Zip/7z.exe" x "$DriveLetter/setup/totalcmd/sftpplug.zip" -o"C:/Program Files/totalcmd/plugins/wfx/sftpplug"
		copy "$DriveLetter/setup/totalcmd/wincmd.*" "C:/Program Files/totalcmd"
	}
	

	$python = Get-Command python -ErrorAction SilentlyContinue

	if ($python) {
		& $python.Source -m pip install --upgrade `
		    pip `
		    WMI `
		    pywin32 `
		    colorama

	} else {

	    Write-Host "Python is niet geïnstalleerd."
	}
	
	# Microsoft Office
	Choice-Install `
	    "Microsoft Office 2024" `
	    "$DriveLetter\setup\microsoft_office_x64_2024\setup.exe" `
	    "/configure", "configuration.xml"
} 

pause


