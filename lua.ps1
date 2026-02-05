$ErrorActionPreference = "Stop"

$uri = "https://github.com/ookami42/ookami42.github.io/releases/latest/download/easy-setup.ps1"

Write-Host "Downloading installer..."
irm $uri | iex
