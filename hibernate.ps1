$taskName = "HibernateTask"
$action = New-ScheduledTaskAction -Execute "shutdown" -Argument "/h"
$trigger = New-ScheduledTaskTrigger -Daily -At "22:00"

# Verifica se a tarefa já existe
$existingTask = Get-ScheduledTask | Where-Object {$_.TaskName -eq $taskName}

if (-not $existingTask) {
    # Cria a tarefa agendada
    Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $taskName -User "SYSTEM" -RunLevel Highest
}