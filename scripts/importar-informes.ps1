param()

$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$entrada = Join-Path $repo 'entrada'
$informes = Join-Path $repo 'informes'
$indice = Join-Path $repo 'README.md'
$registro = Join-Path $repo 'automatizacion.log'

function Registrar([string]$mensaje) {
    Add-Content -LiteralPath $registro -Value ("{0} {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $mensaje) -Encoding UTF8
}

function EscaparCelda([string]$valor) {
    return ($valor -replace '\|', '\|')
}

try {
    if (-not (Test-Path -LiteralPath $entrada)) {
        New-Item -ItemType Directory -Path $entrada | Out-Null
    }

    $archivos = @(Get-ChildItem -LiteralPath $entrada -File | Where-Object {
        $_.Extension.ToLowerInvariant() -in @('.pdf', '.docx', '.md') -and
        $_.LastWriteTime -lt (Get-Date).AddMinutes(-1)
    })

    foreach ($archivo in $archivos) {
        $nombre = [IO.Path]::GetFileNameWithoutExtension($archivo.Name)
        $nombre = $nombre -replace '(?i)^informe[-_ ]*', '' -replace '(?i)[-_ ]*upb$', ''
        if ([string]::IsNullOrWhiteSpace($nombre)) { $nombre = 'Nueva máquina' }
        $slugBase = ([regex]::Replace($nombre.ToLowerInvariant(), '[^\p{L}\p{Nd}]+', '-')).Trim('-')
        if (-not $slugBase) { $slugBase = 'maquina' }
        $slug = $slugBase
        $numero = 2
        while (Test-Path -LiteralPath (Join-Path $informes $slug)) {
            $slug = "$slugBase-$numero"
            $numero++
        }

        $destino = Join-Path $informes $slug
        New-Item -ItemType Directory -Path $destino | Out-Null
        Move-Item -LiteralPath $archivo.FullName -Destination (Join-Path $destino $archivo.Name)

        $nombreVisible = ($nombre -replace '[_-]+', ' ').Trim()
        $nombreVisible = $nombreVisible -replace '[\[\]#*`]', ''
        $enlace = [Uri]::EscapeDataString($archivo.Name)
        $ficha = @"
# $nombreVisible

**Estado:** informe recibido; análisis pendiente  
**Informe original:** [$($archivo.Name)]($enlace)  
**Fecha de incorporación:** $(Get-Date -Format 'yyyy-MM-dd')

## Objetivo y procedimiento

La explicación detallada se encuentra en el informe original. Completar aquí los pasos principales después de revisar la práctica.

## Hallazgos y evidencias

Completar con los resultados observados y las páginas o capturas que los respaldan.

## Aprendizaje defensivo

Completar con las medidas que corresponden a los hallazgos comprobados.
"@
        Set-Content -LiteralPath (Join-Path $destino 'README.md') -Value $ficha -Encoding UTF8

        $metadatos = [ordered]@{
            nombre = $nombreVisible
            plataforma = 'Por clasificar'
            estado = 'Informe recibido'
            resumen = 'Informe original y ficha de seguimiento.'
            archivo = $archivo.Name
        }
        $metadatos | ConvertTo-Json -Depth 3 | Set-Content -LiteralPath (Join-Path $destino 'metadatos.json') -Encoding UTF8
        Registrar "Importado: $($archivo.Name) -> informes/$slug"
    }

    $lineas = New-Object 'System.Collections.Generic.List[string]'
    foreach ($carpeta in @(Get-ChildItem -LiteralPath $informes -Directory | Sort-Object Name)) {
        $rutaMetadatos = Join-Path $carpeta.FullName 'metadatos.json'
        if (-not (Test-Path -LiteralPath $rutaMetadatos)) { continue }
        $datos = Get-Content -LiteralPath $rutaMetadatos -Raw -Encoding UTF8 | ConvertFrom-Json
        $rutaArchivo = 'informes/{0}/{1}' -f $carpeta.Name, [Uri]::EscapeDataString($datos.archivo)
        $nombre = EscaparCelda $datos.nombre
        $plataforma = EscaparCelda $datos.plataforma
        $estado = EscaparCelda $datos.estado
        $resumen = EscaparCelda $datos.resumen
        $lineas.Add("| $nombre | $plataforma | $estado | [Informe]($rutaArchivo) | $resumen |")
    }

    $contenido = Get-Content -LiteralPath $indice -Raw -Encoding UTF8
    $marcaInicio = '<!-- INICIO_INFORMES -->'
    $marcaFin = '<!-- FIN_INFORMES -->'
    $inicio = $contenido.IndexOf($marcaInicio)
    $fin = $contenido.IndexOf($marcaFin)
    if ($inicio -lt 0 -or $fin -le $inicio) { throw 'No se encontraron las marcas de la tabla en README.md.' }
    $prefijo = $contenido.Substring(0, $inicio + $marcaInicio.Length)
    $sufijo = $contenido.Substring($fin)
    $nuevoContenido = $prefijo + "`r`n" + ($lineas -join "`r`n") + "`r`n" + $sufijo
    if ($nuevoContenido -ne $contenido) {
        Set-Content -LiteralPath $indice -Value $nuevoContenido -Encoding UTF8 -NoNewline
    }

    & git -C $repo add -- README.md informes
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo preparar el commit de Git.' }
    $cambios = & git -C $repo diff --cached --name-only
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar el estado de Git.' }
    if ($cambios) {
        & git -C $repo commit -m 'Incorporar informes desde la carpeta de entrada'
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo registrar el commit de Git.' }
    }

    $pendientes = & git -C $repo rev-list --count origin/main..main
    if ($LASTEXITCODE -ne 0) { throw 'No se pudo consultar la sincronización con GitHub.' }
    if ([int]$pendientes -gt 0) {
        & git -C $repo push origin main
        if ($LASTEXITCODE -ne 0) { throw 'No se pudo subir el commit a GitHub.' }
        Registrar "Subidos $pendientes commit(s) a GitHub."
    }
} catch {
    Registrar "ERROR: $($_.Exception.Message)"
    exit 1
}
