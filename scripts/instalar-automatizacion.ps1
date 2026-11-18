$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$procesador = Join-Path $PSScriptRoot 'importar-informes.ps1'
$nombreTarea = 'PortafolioCiberseguridad-ImportarInformes'

if (-not (Test-Path -LiteralPath (Join-Path $repo '.git'))) {
    throw 'La carpeta del portafolio no contiene un repositorio Git.'
}

$autor = & git -C $repo log -1 --format=%an
$correo = & git -C $repo log -1 --format=%ae
if (-not (& git -C $repo config --get user.name)) { & git -C $repo config user.name $autor }
if (-not (& git -C $repo config --get user.email)) { & git -C $repo config user.email $correo }

$ejecutable = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
$accion = New-ScheduledTaskAction -Execute $ejecutable -Argument "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$procesador`"" -WorkingDirectory $repo
$inicio = (Get-Date).AddMinutes(1)
$disparador = New-ScheduledTaskTrigger -Once -At $inicio -RepetitionInterval (New-TimeSpan -Minutes 1) -RepetitionDuration (New-TimeSpan -Days 3650)
$usuario = "$env:USERDOMAIN\$env:USERNAME"
$principal = New-ScheduledTaskPrincipal -UserId $usuario -LogonType Interactive -RunLevel Limited
$configuracion = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Minutes 3) -MultipleInstances IgnoreNew
Register-ScheduledTask -TaskName $nombreTarea -Action $accion -Trigger $disparador -Principal $principal -Settings $configuracion -Description 'Importa informes del portafolio y los sube a GitHub.' -Force | Out-Null

& git -C $repo add -- .gitignore README.md entrada/.gitkeep informes/redeemer/metadatos.json scripts
if ($LASTEXITCODE -ne 0) { throw 'No se pudieron preparar los archivos de la automatización.' }
$cambios = & git -C $repo diff --cached --name-only
if ($cambios) {
    & git -C $repo commit -m 'Automatizar importación y publicación de informes'
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo registrar el commit de la automatización.' }
}
& git -C $repo push origin main
if ($LASTEXITCODE -ne 0) { throw 'La tarea quedó instalada, pero no se pudo subir la automatización a GitHub.' }

Write-Host "Automatización instalada para $usuario. Revisa la carpeta entrada; se procesa cada minuto."
