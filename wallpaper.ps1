$wallpaperFolderPath = "$env:ProgramData\assets" # Caminho para a pasta onde o papel de parede será salvo

$idealWallpaper = "$wallpaperFolderPath\wallpaper_atual.jpg" # Define o caminho para o papel de parede desejado

$githubWallpaperUrl = "https://raw.githubusercontent.com/keepjhonnying/cbc-dstp/refs/heads/main/wallpaper_atual.jpg" # URL novo papel de parede


if (-not (Test-Path -Path $wallpaperFolderPath)) { # Verifica se a pasta existe, se não, cria como oculta
    New-Item -ItemType Directory -Path $wallpaperFolderPath -Force
    (Get-Item $wallpaperFolderPath).Attributes = "Hidden" # Define a pasta como oculta
    Invoke-WebRequest -Uri $githubWallpaperUrl -OutFile $idealWallpaper # Baixa o novo papel de parede
}

if (-not (Test-Path -Path $idealWallpaper)) { # Verifica se o papel de parede desejado já existe
    Invoke-WebRequest -Uri $githubWallpaperUrl -OutFile $idealWallpaper # Se não existir, baixa o novo papel de parede
}

$currentWallpaper = (Get-ItemProperty 'HKCU:\Control Panel\Desktop\' -Name Wallpaper).Wallpaper # Verifica o papel de parede atual

Write-Output(Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper").Wallpaper

if ($currentWallpaper -ne $idealWallpaper) {
    
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $idealWallpaper -Type String # Altera o papel de parede
  
    rundll32.exe user32.dll,UpdatePerUserSystemParameters # Aplica a alteração

}