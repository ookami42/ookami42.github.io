Write-Host "Script obsoleto! Procure outra maneira de instalar o LuaTools" -ForegroundColor Yellow
exit 1
## ================== CONFIG ==================
Clear-Host
$Host.UI.RawUI.WindowTitle = "Luatools Setup | .gg/luatools"
$name = "luatools"
$link = "https://github.com/madoiscool/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"
$milleniumTimer = 3
$version = "v1.0.7 hotfix do hotfix e avisos"
$dllSteamTools = "dwmapi.dll"

## ================ ADMIN CHECK ================
function Ensure-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Tenta de novo e abre O POWERSHELL como ADMINISTRADOR!" -ForegroundColor Red
        for ($i = 10; $i -ge 1; $i--) {
            Write-Host "Vou te fazer o favor de fechar essa janela em $i..." -ForegroundColor Yellow -NoNewline
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
$lang = "BR"
## ================== HEADER MSG ==================

Write-Host "====================================================" -ForegroundColor White
Write-Host ""
Write-Host "  Bem-vindo ao Instalador Caminho Facil do LuaTools" -ForegroundColor Cyan
Write-Host "  Se vc pagou por esse script, vc foi enganado :)" -ForegroundColor Cyan
Write-Host ""
Write-Host "====================================================" -ForegroundColor White

Start-Sleep 1

Write-Host ""
Write-Host "  SE APARECER ALGUM ERRO ESTRANHO" -ForegroundColor Red
Write-Host "  E SE A STEAM NAO ABRIR" -ForegroundColor Red
Write-Host "  Tira print de TODAS as mensagem dessa tela" -ForegroundColor Yellow
Write-Host "  E manda em discord.com/invite/luatools" -ForegroundColor Yellow
Write-Host ""
Write-Host "====================================================" -ForegroundColor White

Start-Sleep 4

Write-Host "  Preparando para instalar..." -ForegroundColor Green -NoNewline

$headerTimer = 3
for ($i = $headerTimer; $i -gt -1; $i--) {
    Write-Host "  $i segundo(s)" -ForegroundColor Magenta -NoNewline
    Start-Sleep 1
    Write-Host "`r  Preparando para instalar..." -ForegroundColor Green -NoNewline
}

Write-Host ""
Write-Host "====================================================" -ForegroundColor White
Write-Host ""

## ================== CONFIG ==================

$T = @{
    EN = @{
        STEAMTOOLS_OK      = "Steamtools already installed"
        STEAMTOOLS_MISSING = "Steamtools not found."
        STEAMTOOLS_INSTALL = "Steamtools reinstalled successfully"
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
        ANTI_VIRUS_ON      = "Antivirus turned on."
        ANTI_VIRUS_OFF     = "Antivirus turned off."
        err_anti           = "ANTIVIRUS ERROR"
        Exclusion          = "ADDING AN EXCLUSION TO THE FOLDER C:\Program Files (x86)\Steam"
        WAITFEWSECONDS     = "Please wait a few seconds for Steam to fully load."
        exclusion_in_pc    = "Exclusion already exists"
        millenium          = "Millenium issues."
        stop_steam1        = ""
        stop_steam2        = ""
        millenium_log      = ""
    }
    BR = @{
        STEAMTOOLS_OK      = "Steamtools ja esta instalado"
        STEAMTOOLS_MISSING = "Steamtools nao encontrado."
        STEAMTOOLS_INSTALL = "Steamtools reinstalado com sucesso."
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
        WAIT               = "Nao feche o script ainda. Verifica se deu bom e manda print se deu ruim."
        DONE               = "Tudo feito."
        ANTI_VIRUS_ON      = "AntiVirus ligado."
        ANTI_VIRUS_OFF     = "AntiVirus desligado."
        err_anti           = "ERRO NO ANTIVIRUS"
        Exclusion          = "ADICIONANDO UMA EXCLUSÃO NA PASTA C:\Program Files (x86)\Steam"
        WAITFEWSECONDS     = "Aguarde uns segundos ate a Steam abrir completamente"
        exclusion_in_pc    = "Exclusao ja existe"
        millenium          = "Erro ao tentar instalar o Millenium."
        stop_steam1        = "Fechei a Steam pra instalar tudo tranquilo."
        stop_steam2        = "No final vou abrir de novo."
        millenium_log      = "O Millenium vai falar em english, pode ignorar de boa."
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

$steamExclusion = "C:\Program Files (x86)\Steam"

try {
    $exclusions = @((Get-MpPreference).ExclusionPath)

    if ($exclusions -contains $steamExclusion) {
        Log "INFO" (L "exclusion_in_pc")
    }
    else {
        Add-MpPreference -ExclusionPath $steamExclusion -ErrorAction Stop
        Log "LOG" (L "Exclusion")
    }
}
catch {
    Log "ERR" (L "err_anti")
    Log "ERR" $_.Exception.Message
}

Log "VERSION" "$version"

## ================== STOP STEAM ==================
Log "INFO" (L stop_steam1)
Log "INFO" (L stop_steam2)
Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep 2


## ================== STEAMTOOLS ==================
$pathSteamTools = Join-Path $steam $dllSteamTools

$script = Invoke-RestMethod "https://steam.run"
$filtered = (
    ($script -split "`n") | Where-Object {
        $_ -notmatch "steam\.exe|Start-Sleep|Write-Host|cls|exit"
    }
) -join "`n"

for ($i = 0; $i -lt 5; $i++) {
    Log "WARN" (L INSTALLING_ST)
    Invoke-Expression $filtered *> $null

    if (Test-Path $dllSteamTools) { break }
    Log "ERR" (L INSTALL_FAIL)
    Start-Sleep 2
}
Log "INFO" (L STEAMTOOLS_INSTALL)

## ================== MILLENIUM ==================

$extPath = Join-Path $steam "ext"

if (Test-Path $extPath -PathType Container) {
    Remove-Item $extPath -Recurse -Force
} else {
    Log "LOG" (L MILL_MISSING)
}
          
## ====================== ANTIVIRUS OFF ======================
Try {
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop
    Log "WARN" (L ANTI_VIRUS_OFF)
}
Catch {
    Log "ERR" (L err_anti)
}

for ($i = $milleniumTimer; $i -gt 0; $i--) {
    Write-Host "$i" -ForegroundColor Magenta -NoNewline
    Start-Sleep 1
    Write-Host "`r" -NoNewline
}
Log "INFO" (L millenium_log)

Try {
    Invoke-Expression "& { $(Invoke-RestMethod 'https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1') } -DontStart -SteamPath '$steam'"
    Log "INFO" (L MILL_OK)
} catch {
    Log "WARN" (L millenium)
    Log "WARN" $_.Exception.Message
}



## ====================== ANTIVIRUS ON ======================
Try {
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction Stop
    Log "WARN" (L ANTI_VIRUS_ON)
}
Catch {
    Log "ERR" (L err_anti)
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
Log "WARN" (L WAIT)



# CREDITS: clem.la, melly, Yuki (boas._.), ookami42
