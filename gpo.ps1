# Define a lista de aplicativos permitidos
$allowedApps = @("App1.exe", "App2.exe", "App3.exe")
$gpoPath = "HKCU:\Software\Policies\Microsoft\Windows\Safer\CodeIdentifiers"

# Verifica se a configuração está presente
$allowedAppsFromGpo = Get-ItemProperty $gpoPath -Name "Paths" -ErrorAction SilentlyContinue

if (-not $allowedAppsFromGpo) {
    # Aplica os aplicativos permitidos na GPO
    New-Item -Path $gpoPath -Force
    Set-ItemProperty -Path $gpoPath -Name "Paths" -Value ($allowedApps -join ";")
}