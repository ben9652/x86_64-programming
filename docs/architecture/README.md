# Architecture Documentation

Esta carpeta contiene documentación sobre la arquitectura x86_64 y convenciones específicas de Windows.

## Archivos incluidos:

### `windows_calling_convention.txt`
Documentación detallada sobre las convenciones de llamadas de Windows x64:
- Alignment de stack
- Shadow space
- Preservación de registros
- Parámetros y valores de retorno

### `stack_corruption_demo.txt`
Ejemplos y análisis de problemas de corrupción del stack:
- Casos comunes de stack corruption
- Cómo identificar problemas
- Patrones de debugging
- Soluciones implementadas

## Uso recomendado:
1. Estudiar `windows_calling_convention.txt` antes de escribir funciones
2. Consultar `stack_corruption_demo.txt` al debugging de problemas de stack