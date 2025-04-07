# Função para centralizar texto
function Center-Text {
    param ([string]$text)
    $consoleWidth = [console]::WindowWidth
    $padLeft = [Math]::Max(0, ($consoleWidth - $text.Length) / 2)
    return ' ' * $padLeft + $text
}

# ASCII
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
#[void][System.Console]::ReadKey($true)

# Verifica se é administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Execute este script como administrador..." -ForegroundColor Red -BackgroundColor White
    exit
}

# Caminhos
$assetsFolderPath = "$env:ProgramData\cbc-assets"
if (-not (Test-Path -Path $assetsFolderPath)) {
    New-Item -ItemType Directory -Path $assetsFolderPath -Force | Out-Null
    (Get-Item $assetsFolderPath).Attributes = "Hidden"
}

# Verificação de versão
$localVersionFile = Join-Path $assetsFolderPath "version.txt"
$githubVersionUrl = "https://raw.githubusercontent.com/keepjhonnying/cbc-dstp/refs/heads/main/version.txt"

try {
    $remoteVersion = (Invoke-WebRequest -Uri $githubVersionUrl -UseBasicParsing).Content.Trim()
} catch {
    Write-Host "Não foi possível obter a versão remota." -ForegroundColor Yellow
    $remoteVersion = ""
}

$localVersion = ""
if (Test-Path $localVersionFile) {
    $localVersion = Get-Content $localVersionFile -Raw | ForEach-Object { $_.Trim() }
}

# Lista de arquivos a excluir se a versão for diferente
$arquivosParaExcluir = @("wallpaper.exe", "version.txt")

if ($remoteVersion -and $localVersion -ne $remoteVersion) {
    Write-Host "Atualização disponível. Atualizando arquivos..." -ForegroundColor Yellow

    foreach ($arquivo in $arquivosParaExcluir) {
        $path = Join-Path $assetsFolderPath $arquivo
        if (Test-Path $path) {
            Remove-Item $path -Force
            Write-Host "Removido: $arquivo"
        }
    }

    # Baixa nova versão.txt
    Invoke-WebRequest -Uri $githubVersionUrl -OutFile $localVersionFile
    Write-Host "Versão atualizada para: $remoteVersion"
} else {
    Write-Host "Versão atualizada. Nenhuma ação necessária." -ForegroundColor Green
}

# URLs dos scripts
$scriptUrls = @{
    "wallpaper.exe" = "https://github.com/keepjhonnying/cbc-dstp/releases/download/test/main.exe"
}

# Criar tarefas agendadas
foreach ($script in $scriptUrls.GetEnumerator()) {
    $scriptName = $script.Key
    $scriptUrl  = $script.Value
    $scriptPath = Join-Path $assetsFolderPath $scriptName
    $taskFolder = "\CEBRAC"
    $taskName   = "$taskFolder\task_" + [IO.Path]::GetFileNameWithoutExtension($scriptName)

    Write-Host $taskName -ForegroundColor Red -BackgroundColor White
    #[void][System.Console]::ReadKey($true)

    # Baixa o executável se não existir
    if (-not (Test-Path $scriptPath)) {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
        Write-Host "Executável baixado: $scriptName"
    }

    # Remove tarefa existente
    schtasks /Delete /TN $taskName /F > $null 2>&1

    # Cria tarefa para o logon do sistema
    schtasks /Create `
        /TN $taskName `
        /TR "`"$scriptPath`"" `
        /SC ONLOGON `
        /RU SYSTEM `
        /RL HIGHEST `
        /F

    Write-Host "Tarefa agendada criada: $taskName"
}
