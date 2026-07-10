<#
.SYNOPSIS
Name : sftpplug.ps1

.DESCRIPTION
Description : Incremental backup naar USB-disk v2.0 (c) HC 2004-2025 ...

.NOTES
Author	: H. Celik
Version	: 1.1
Date	: 16-01-2016,10-07-2026 H. Celik
#>

function Find-DriveLetter {
    param(
        [string[]]$VolumeNames
    )

    foreach ($volume in Get-Volume | Where-Object DriveLetter) {
        if ($VolumeNames -contains $volume.FileSystemLabel) {
            return "$($volume.DriveLetter):"
        }
    }

    return $null
}

function Install-TotalCommander {

    if ((Read-Host "`nInstall Total Commander SFTP plugin? (y/N)").ToLower() -ne "y") {
        return
    }

    $url       = "https://www.totalcommander.ch/win/fs/sftpplug.zip"
    $zip       = Join-Path $env:TEMP "sftpplug.zip"
    $tcDir     = "C:\Program Files\totalcmd"
    $pluginDir = "$tcDir\plugins\wfx\sftpplug"
    $plugin    = "$pluginDir\sftpplug.wfx"

    if (!(Test-Path "C:\Program Files\7-Zip\7z.exe")) {
        Write-Host "7-Zip is not installed." -ForegroundColor Red
        return
    }

    if (!(Test-Path "$tcDir\TOTALCMD64.EXE")) {
        Write-Host "Total Commander is not installed." -ForegroundColor Red
        return
    }

    Write-Host "Downloading SFTP plugin..."
    Invoke-WebRequest -Uri $url -OutFile $zip

    New-Item -ItemType Directory -Force -Path $pluginDir | Out-Null

    & "C:\Program Files\7-Zip\7z.exe" x `
        $zip `
        "-o$pluginDir" `
        -y | Out-Null

    Remove-Item $zip -Force

    if (Test-Path $plugin) {
        & "$tcDir\TOTALCMD64.EXE" /O /S=$plugin
        Write-Host "SFTP plugin installed." -ForegroundColor Green
    } else {
        Write-Host "Plugin registration failed: $plugin not found." -ForegroundColor Red
    }

    Copy-Item `
        "$DriveLetter\setup\totalcmd\wincmd.*" `
        "C:\Program Files\totalcmd" 
        -Force
}

function Install-Office {
    if ((Read-Host "`nInstall Microsoft office? (y/N)").ToLower() -ne "y") {
        return
    }
    
    $setup = "$DriveLetter\setup\microsoft_office_x64_2024\setup.exe"
    $config = "$DriveLetter\setup\microsoft_office_x64_2024\configuration.xml"

    if (!(Test-Path $setup)) {
        Write-Host "Office setup not found: $setup" -ForegroundColor Red
        return
    }

    if (!(Test-Path $config)) {
        Write-Host "Office configuration not found: $config" -ForegroundColor Red
        return
    }

    Write-Host "Installing Microsoft Office 2024..." -ForegroundColor Cyan

    Start-Process `
        -FilePath $setup `
        -ArgumentList "/configure", $config `
        -Wait

    Write-Host "Microsoft Office installation finished." -ForegroundColor Green
}


$DriveLetter = Find-DriveLetter `
    "NVMe4-2T",
    "ssd1-2T"

if (-not $DriveLetter) {
    Write-Host "Installation disk not found." -ForegroundColor Red
    pause
    return
} else {
    Write-Host "Found: $($DriveLetter)" -ForegroundColor Green
}

Install-TotalCommander
Install-Office

Read-Host "`nPress ENTER to exit"

