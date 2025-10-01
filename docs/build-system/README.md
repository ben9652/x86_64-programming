# Build System Documentation

Esta carpeta está destinada a documentación del sistema de build del proyecto.

## Estructura del Build System:

El proyecto utiliza un Makefile profesional con las siguientes características:
- Configuraciones Debug y Release separadas
- Directorios de salida organizados (`bin/Debug`, `bin/Release`)
- Modo verbose controlable
- Limpieza automática de archivos temporales

## Archivos futuros:
- Documentación detallada del Makefile
- Guías de configuración de build
- Instrucciones para diferentes toolchains
- Configuraciones de optimización

## Targets principales del Makefile:
- `make` - Build en modo Debug
- `make release` - Build optimizado para Release
- `make verbose` - Build con salida detallada
- `make clean` - Limpieza de archivos temporales