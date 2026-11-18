# Portafolio de Ciberseguridad

Repositorio personal para documentar mi aprendizaje práctico en ciberseguridad. Aquí organizo informes, procedimientos reproducibles, evidencias y aprendizajes de máquinas realizadas en laboratorios autorizados.

## Informes

| Máquina | Plataforma | Estado | Informe | Resumen |
|---|---|---|---|---|
| Redeemer | Hack The Box — Starting Point | Completada | [Informe académico (PDF)](informes/redeemer/Informe_Redeemer_UPB.pdf) | Reconocimiento TCP e inspección de una instancia Redis accesible sin autenticación. |

## Estructura

```text
informes/
  redeemer/
    Informe_Redeemer_UPB.pdf
    README.md
plantillas/
  PLANTILLA_INFORME.md
```

Cada carpeta de máquina conserva el informe original y un resumen navegable con objetivo, entorno, procedimiento, hallazgo, mitigaciones y trazabilidad de evidencias. Para añadir una máquina, copia la plantilla, crea `informes/<slug>/` y actualiza la tabla de este README.

## Alcance y uso responsable

Las actividades documentadas se realizaron en laboratorios autorizados. Los comandos de reconocimiento y explotación deben ejecutarse únicamente contra objetivos para los que se tenga autorización. Las direcciones IP de laboratorios pueden cambiar entre sesiones; usa siempre los datos de tu propia ejecución.

## Sobre las evidencias

El PDF Redeemer incluye capturas de la sesión de laboratorio y una bitácora que vincula cada fase con su resultado. El resumen de la carpeta deja claro qué se observó y qué no se probó. Las banderas de plataformas son datos de laboratorio; evita reutilizarlas como credenciales o publicarlas fuera de este contexto.
