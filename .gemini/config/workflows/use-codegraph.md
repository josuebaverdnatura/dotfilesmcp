---
description: use-codegraph
---

# Optimización de Tokens con CodeGraph

**Nombre sugerido para el Workflow:** `Use CodeGraph`
**Comando sugerido:** `/codegraph`

Copia el siguiente texto y pégalo en la ventana de **Customizations > Workflows > + Workspace**:

```text
Recordatorio CRÍTICO de optimización de tokens:

A partir de este momento, estás obligado a utilizar la librería `.codegraph` configurada en este proyecto para explorar la arquitectura y dependencias antes de leer archivos completos. 

Reglas de uso:
1. No utilices la herramienta `view_file` para leer archivos masivos "a ciegas" para entender cómo se conectan los módulos.
2. Interroga la base de datos `codegraph.db` (usando comandos sqlite3) o utiliza los comandos proporcionados por la CLI de CodeGraph para descubrir referencias, funciones y dependencias.
3. Solo cuando sepas exactamente qué fragmento o archivo necesitas modificar, procede a leerlo y editarlo.
4. Tu objetivo es mantener el consumo de contexto (tokens) lo más bajo y preciso posible.
```

