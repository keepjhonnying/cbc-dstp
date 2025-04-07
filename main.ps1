function Center-Text {
    param ([string]$text)
    $consoleWidth = [console]::WindowWidth
    $padLeft = [Math]::Max(0, ($consoleWidth - $text.Length) / 2)
    return ' ' * $padLeft + $text
}

$asciiLines = @'
 ░▒▓███████▓▒░░▒▓██████▓▒░░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░▒▓████████▓▒░ 
░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
░▒▓█▓▒░      ░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░ ░▒▓█▓▒░     
 ░▒▓██████▓▒░░▒▓█▓▒░      ░▒▓███████▓▒░░▒▓█▓▒░▒▓███████▓▒░  ░▒▓█▓▒░     
       ░▒▓█▓▒░▒▓█▓▒░      ░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░     
       ░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░     
░▒▓███████▓▒░ ░▒▓██████▓▒░░▒▓█▓▒░░▒▓█▓▒░▒▓█▓▒░▒▓█▓▒░        ░▒▓█▓▒░     
                                                                       
'@ -split "`n"

foreach ($line in $asciiLines) {
    Write-Host (Center-Text $line) -ForegroundColor Cyan
}

Write-Host ""
Write-Host (Center-Text "Desenvolvido por Jhonny Ilis") -ForegroundColor White
Write-Host ""
Write-Host (Center-Text "Pressione qualquer tecla para iniciar...") -ForegroundColor Green

# Aguarda uma tecla
[void][System.Console]::ReadKey($true)



# Requer permissão de administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    #Write-Error "Execute este script como administrador."]
    Write-Host "Execute este script como administrador...." -ForegroundColor Red -BackgroundColor White
    exit
}


# Caminho para a pasta onde os scripts serão salvos (acessível a todos os usuários)
$assetsFolderPath = "$env:ProgramData\cbc-assets"
if (-not (Test-Path -Path $assetsFolderPath)) {
    New-Item -ItemType Directory -Path $assetsFolderPath -Force | Out-Null
    (Get-Item $assetsFolderPath).Attributes = "Hidden"
}

# URLs dos scripts PowerShell hospedados
$scriptUrls = @{
    "wallpaper.ps1" = "https://raw.githubusercontent.com/keepjhonnying/cbc-dstp/refs/heads/main/wallpaper.ps1"
    #"outro.ps1" = "https://raw.githubusercontent.com/exemplo/outro.ps1"
}



# Para cada script
foreach ($script in $scriptUrls.GetEnumerator()) {
    $scriptName = $script.Key
    $scriptUrl  = $script.Value
    $scriptPath = Join-Path $assetsFolderPath $scriptName
    $batName    = [IO.Path]::GetFileNameWithoutExtension($scriptName) + ".bat"
    $batPath    = Join-Path $assetsFolderPath $batName
    $serviceName = "svc_" + [IO.Path]::GetFileNameWithoutExtension($scriptName)

    # Baixa o script se não existir
    if (-not (Test-Path $scriptPath)) {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
        Write-Host "Script baixado: $scriptName"
    }

    # Cria o .bat que chama o script com PowerShell oculto
    $batContent = "@echo off`r`nPowerShell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`""
    Set-Content -Path $batPath -Value $batContent -Encoding ASCII

    # Cria o serviço se ainda não existir
    $existing = sc.exe query $serviceName 2>&1
    if ($existing -notmatch "SERVICE_NAME") {
        sc.exe create $serviceName binPath= "\"$batPath\"" start= auto DisplayName= "\"$serviceName\"" description= $serviceName "Serviço para executar $scriptName como SYSTEM"
        Write-Host "Serviço criado: $serviceName"
    } else {
        Write-Host "Serviço já existe: $serviceName"
    }

    # Inicia o serviço
    Start-Service -Name $serviceName
}
