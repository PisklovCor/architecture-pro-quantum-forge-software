# PowerShell скрипт для настройки планировщика задач Windows
# Запускает update_index.py каждый день в 6:00

$TaskName = "UpdateKnowledgeBaseIndex"
$ScriptPath = Join-Path $PSScriptRoot "update_index.py"
$PythonPath = (Get-Command python).Source

# Проверка существования задачи
$existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

if ($existingTask) {
    Write-Host "Задача '$TaskName' уже существует. Удаляю старую задачу..."
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}

# Создание действия (запуск скрипта)
$Action = New-ScheduledTaskAction -Execute $PythonPath -Argument "`"$ScriptPath`"" -WorkingDirectory $PSScriptRoot

# Создание триггера (каждый день в 6:00)
$Trigger = New-ScheduledTaskTrigger -Daily -At 6:00AM

# Настройки задачи
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Создание задачи
$Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive

Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -Settings $Settings -Principal $Principal -Description "Автоматическое обновление векторного индекса базы знаний"

Write-Host "Задача '$TaskName' успешно создана!"
Write-Host "Задача будет запускаться каждый день в 6:00"
Write-Host ""
Write-Host "Для просмотра задачи используйте:"
Write-Host "  Get-ScheduledTask -TaskName '$TaskName'"
Write-Host ""
Write-Host "Для удаления задачи используйте:"
Write-Host "  Unregister-ScheduledTask -TaskName '$TaskName' -Confirm:`$false"

