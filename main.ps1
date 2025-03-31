# Caminho para a pasta onde os scripts serão salvos
$assetsFolderPath = "C:\assets"

# URLs dos scripts PowerShell hospedados no GitHub
$scriptUrls = @{
    "script1.ps1" = "https://raw.githubusercontent.com/usuario/repositorio/main/script1.ps1"
    "script2.ps1" = "https://raw.githubusercontent.com/usuario/repositorio/main/script2.ps1"
    "script3.ps1" = "https://raw.githubusercontent.com/usuario/repositorio/main/script3.ps1"
    "script4.ps1" = "https://raw.githubusercontent.com/usuario/repositorio/main/script4.ps1"
}

# Verifica se a pasta existe, se não, cria como oculta
if (-not (Test-Path -Path $assetsFolderPath)) {
    New-Item -ItemType Directory -Path $assetsFolderPath -Force
    (Get-Item $assetsFolderPath).Attributes = "Hidden" # Define a pasta como oculta
}

# Função para baixar scripts e criar tarefas agendadas
function CheckAndDownloadScript {
    param (
        [string]$scriptName,
        [string]$scriptUrl
    )
    
    $scriptPath = Join-Path -Path $assetsFolderPath -ChildPath $scriptName

    # Verifica se o script já existe
    if (-not (Test-Path -Path $scriptPath)) {
        # Se não existir, baixa o script do GitHub
        Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath
        Write-Host "Script baixado: $scriptName"

        # Criação da tarefa agendada
        $taskName = "Task_$scriptName"

        # Verifica se a tarefa já existe
        $existingTask = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName}

        if (-not $existingTask) {
            # Se a tarefa não existir, cria a tarefa agendada
            $action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""
            $trigger = New-ScheduledTaskTrigger -AtLogOn  # Ajuste o trigger conforme necessário
            
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -User "SYSTEM" -RunLevel Highest
            Write-Host "Tarefa agendada criada: $taskName"
        } else {
            Write-Host "Tarefa já existe: $taskName"
        }
    } else {
        Write-Host "Script já existe: $scriptName"
    }
}

# Verifica e baixa cada script
foreach ($script in $scriptUrls.GetEnumerator()) {
    CheckAndDownloadScript -scriptName $script.Key -scriptUrl $script.Value
}