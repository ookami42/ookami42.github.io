## ================== CONFIG ==================
Clear-Host
$Host.UI.RawUI.WindowTitle = "Luatools Setup | .gg/luatools"
$name = "luatools"
$link = "https://github.com/madoiscool/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
$milleniumTimer = 5
$version = "30"

## ================ ADMIN CHECK ================
function Ensure-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "ERR: RUN POWERSHELL AS ADMINISTRATOR" -ForegroundColor Red
        for ($i = 10; $i -ge 1; $i--) {
            Write-Host "Closing Window in $i..." -ForegroundColor Yellow -NoNewline
            Start-Sleep 1
            Write-Host "`r" -NoNewline
        }
        Write-Host ""
        exit
    }
}

Ensure-Admin

## ================== INTERNAL ==================
$steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam").InstallPath
$upperName = $name.Substring(0, 1).ToUpper() + $name.Substring(1).ToLower()

$ProgressPreference = 'SilentlyContinue'
## ================== LANGUAGE ==================
$lang = "EN"


Write-Host "====================================" -ForegroundColor White
Write-Host " What is your language?" -ForegroundColor Cyan
Write-Host " Qual seu idioma?" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor White
Write-Host ""
Write-Host "[1] English" -ForegroundColor Red
Write-Host "[2] Portugues (BR)" -ForegroundColor Green
Write-Host

do {
    Write-Host "Select / Selecione: " -NoNewline -ForegroundColor White
    $choice = Read-Host
} until ($choice -in @("1", "2"))

if ($choice -eq "2") { $lang = "BR" }


$T = @{
    EN = @{
        STEAMTOOLS_OK      = "Steamtools already installed"
        STEAMTOOLS_MISSING = "Steamtools not found."
        INSTALLING_ST      = "Installing Steamtools"
        INSTALL_FAIL       = "Steamtools installation failed, retrying..."
        MILL_MISSING       = "Millenium not found, installation will start in 5 seconds."
        INSTALL_CANCEL     = "Installation cancelled by user."
        MILL_OK            = "Millenium already installed"
        DOWNLOADING        = "Downloading"
        UNZIPPING          = "Unzipping"
        INSTALLED          = "installed"
        PLUGIN_ENABLED     = "Plugin enabled"
        STARTING_STEAM     = "Starting Steam"
        WAIT               = "Don't close the script yet"
        DONE               = "Job done, you can close this."
        Exclusion          = "ADDING AN EXCLUSION TO THE FOLDER C:\Program Files (x86)\Steam"
        WAITFEWSECONDS     = "Please wait a few seconds for Steam to fully load."
        exclusion_in_pc    = "Exclusion already exists"
        antivirus_REQUEST = "I really recommend you turn off yourself your ANTIVIRUS"
        antivirus_REQUEST2 = "If you don't disable it, errors may occur in your Steam and Millennium applications."
        exclusion_in_pc_Err = "Error while trying to add the exclusion."
        antivirus_REQUEST_option_go = "[1] Continue"
        antivirus_REQUEST_option_leave = "[2] Leave"
    }
    BR = @{
        STEAMTOOLS_OK      = "Steamtools ja esta instalado"
        STEAMTOOLS_MISSING = "Steamtools nao encontrado."
        INSTALLING_ST      = "Instalando Steamtools"
        INSTALL_FAIL       = "Falha ao instalar Steamtools, tentando novamente..."
        MILL_MISSING       = "Millenium nao encontrado, instalacao comecara em 5 segundos."
        INSTALL_CANCEL     = "Instalacao cancelada pelo usuario."
        MILL_OK            = "Millenium ja instalado"
        DOWNLOADING        = "Baixando"
        UNZIPPING          = "Extraindo"
        INSTALLED          = "instalado"
        PLUGIN_ENABLED     = "Plugin ativado"
        STARTING_STEAM     = "Iniciando Steam"
        WAIT               = "Nao feche o script ainda"
        DONE               = "Tudo pronto, pode fechar."
        Exclusion          = "ADICIONANDO UMA EXCLUSAO NA PASTA C:\Program Files (x86)\Steam"
        WAITFEWSECONDS     = "Aguarde uns segundos ate a Steam abrir completamente"
        exclusion_in_pc    = "Exclusao ja existe"
        antivirus_REQUEST = "Recomendo fortemente que voce desligue seu antivirus."
        antivirus_REQUEST2 = "Se voce nao desativar podera ocorrer erros na sua Steam e no Millenium."
        exclusion_in_pc_Err = "Erro ao tentar adicionar a excluso"
        antivirus_REQUEST_option_go = "[1] Continuar"
        antivirus_REQUEST_option_leave = "[2] Sair"
    }
}

function L { param($k) return $T[$lang][$k] }


## ================== LOG ==================
function Log {
    param ([string]$Type, [string]$Message)

    $colors = @{
        OK = "Green"; INFO = "Cyan"; ERR = "Red"; WARN = "Yellow"; LOG = "Magenta"; AUX = "DarkGray"; VERSION = "DarkYellow"
    }

    $date = Get-Date -Format "HH:mm:ss"
    Write-Host "[$date] " -NoNewline -ForegroundColor Cyan
    Write-Host "[$Type] $Message" -ForegroundColor $colors[$Type]
}

Log "WARN" (L antivirus_REQUEST)
LOG "WARN" (L antivirus_REQUEST2)
Write-Host ""
Log "INFO" (L antivirus_REQUEST_option_go)
Log "INFO" (L antivirus_REQUEST_option_leave)

do {
    $choice = Read-Host
} until ($choice -in @("1", "2"))

if ($choice -eq "2") { exit }

$steamExclusion = "C:\Program Files (x86)\Steam"
$exclusions = (Get-MpPreference).ExclusionPath

if ($exclusions -contains $steamExclusion) {
    Log "INFO" (L exclusion_in_pc)
}
else {
    Try {
        Add-MpPreference -ExclusionPath $steamExclusion -ErrorAction Stop
        Log "LOG" (L Exclusion)
    }
    Catch {
        Log "ERR" (L exclusion_in_pc_Err)
    }
}



Log "VERSION" "$version"

## ================== STOP STEAM ==================
Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2


## ================== STEAMTOOLS ==================
$path = Join-Path $steam "xinput1_4.dll"

if (Test-Path $path) {
    Log "INFO" (L STEAMTOOLS_OK)
}
else {
    $script = Invoke-RestMethod "https://steam.run"
    $filtered = (
        ($script -split "`n") | Where-Object {
            $_ -notmatch "steam\.exe|Start-Sleep|Write-Host|cls|exit"
        }
    ) -join "`n"

    for ($i = 0; $i -lt 5; $i++) {
        Log "WARN" (L INSTALLING_ST)
        Invoke-Expression $filtered *> $null

        if (Test-Path $path) { break }
        Log "ERR" (L INSTALL_FAIL)
        Start-Sleep 2
    }

}


## ================== MILLENIUM ==================

$milleniumInstalling = $false

foreach ($f in @("millennium.dll", "python311.dll")) {
    if (!(Test-Path (Join-Path $steam $f))) {




        Log "LOG" (L MILL_MISSING)
        
        for ($i = $milleniumTimer; $i -gt 0; $i--) {
            Write-Host "$i" -ForegroundColor Magenta -NoNewline
            Start-Sleep 1
            Write-Host "`r" -NoNewline
        }
        Write-Host ""

        Invoke-Expression "& { $(Invoke-RestMethod 'https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1') } -NoLog -DontStart -SteamPath '$steam'"
        $milleniumInstalling = $true
        break
    }
}

if ($milleniumInstalling) {


}
else {
    Log "INFO" (L MILL_OK)
}

## ================== PLUGIN ==================
$pluginsDir = Join-Path $steam "plugins"
if (!(Test-Path $pluginsDir)) {
    New-Item $pluginsDir -ItemType Directory | Out-Null
}

$Path = Join-Path $pluginsDir $name
$tempZip = Join-Path $env:TEMP "$name.zip"

Log "LOG" "$(L DOWNLOADING) $name"
Invoke-WebRequest $link -OutFile $tempZip *> $null

Log "LOG" "$(L UNZIPPING) $name"
Expand-Archive $tempZip $Path -Force *> $null
Remove-Item $tempZip -Force

Log "OK" "$upperName $(L INSTALLED)"

## ================== ENABLE ==================
$configPath = Join-Path $steam "ext/config.json"

if (-not (Test-Path $configPath)) {
    New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null

    $config = [PSCustomObject]@{
        plugins = @{
            enabledPlugins = @($name)
        }
    }
}
else {
    $config = Get-Content $configPath -Raw -Encoding UTF8 | ConvertFrom-Json

    if (-not $config.plugins) {
        $config | Add-Member plugins ([PSCustomObject]@{}) -Force
    }
    if (-not $config.plugins.enabledPlugins) {
        $config.plugins.enabledPlugins = @()
    }

    if ($config.plugins.enabledPlugins -notcontains $name) {
        $config.plugins.enabledPlugins += $name
    }
}
$config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8

Log "OK" (L PLUGIN_ENABLED)

## ================== START STEAM ==================
Start-Process (Join-Path $steam "steam.exe") "-clearbeta"
Log "INFO" (L STARTING_STEAM)

Log "OK" (L DONE)


# CREDITS: clem.la, melly, Yuki (boas._.)
