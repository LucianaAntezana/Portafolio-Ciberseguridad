# Portafolio de Ciberseguridad

Repositorio personal para documentar mi aprendizaje práctico en ciberseguridad. Aquí organizo informes, procedimientos reproducibles, evidencias y aprendizajes de máquinas realizadas en laboratorios autorizados.

## Informes

| Máquina | Plataforma | Estado | Informe | Resumen |
|---|---|---|---|---|
<!-- INICIO_INFORMES -->
| Redeemer | Hack The Box — Starting Point | Completada | [Informe académico (PDF)](informes/redeemer/Informe_Redeemer_UPB.pdf) | Reconocimiento TCP e inspección de una instancia Redis accesible sin autenticación. |
<!-- FIN_INFORMES -->

## Añadir informes automáticamente

Deposita un archivo PDF, DOCX o Markdown en la carpeta [`entrada`](entrada/). Una tarea de Windows revisa esa carpeta cada minuto. Cuando el archivo lleva al menos un minuto sin cambios, lo mueve a `informes/<nombre>/`, crea una ficha básica, actualiza esta tabla, registra un commit y lo sube a GitHub.

La ficha automática identifica el archivo y deja espacios para el análisis técnico. El informe original es la evidencia publicada; para obtener una explicación revisada como la de Redeemer, hay que analizar cada práctica por separado. Revisa los archivos antes de colocarlos en `entrada`, ya que este repositorio es público.

Para activar la tarea una vez, abre PowerShell con tu usuario y ejecuta `powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/instalar-automatizacion.ps1` desde la raíz del repositorio. El estado de cada ejecución queda en `automatizacion.log` (archivo local, excluido de Git). La tarea se llama `PortafolioCiberseguridad-ImportarInformes`.

## Estructura

```text
informes/
  redeemer/
    Informe_Redeemer_UPB.pdf
    README.md
plantillas/
  PLANTILLA_INFORME.md
```

Cada carpeta de máquina conserva el informe original y una ficha navegable. La plantilla permite ampliar la explicación con objetivo, entorno, procedimiento, hallazgo, mitigaciones y trazabilidad de evidencias.

## Alcance y uso responsable

Las actividades documentadas se realizaron en laboratorios autorizados. Los comandos de reconocimiento y explotación deben ejecutarse únicamente contra objetivos para los que se tenga autorización. Las direcciones IP de laboratorios pueden cambiar entre sesiones; usa siempre los datos de tu propia ejecución.

## Sobre las evidencias

El PDF Redeemer incluye capturas de la sesión de laboratorio y una bitácora que vincula cada fase con su resultado. El resumen de la carpeta deja claro qué se observó y qué no se probó. Las banderas de plataformas son datos de laboratorio; evita reutilizarlas como credenciales o publicarlas fuera de este contexto.
