---
description: use-qwen3.7
---

# Flujo de Trabajo: Contraste de Modelos y Debate con Qwen 3.7 Max y DeepSeek (OpenCode Go)

**Nombre del Workflow:** `Use Qwen 3.7 & DeepSeek (OpenCode Go)`
**Comando sugerido:** `/use-qwen3.7`

Este workflow establece las pautas para iniciar un panel de debate automático usando OpenCode Go cuando surgen dudas de diseño, algoritmos complejos, refactorizaciones críticas o problemas de rendimiento.

---

## 1. Cuándo Invocar este Workflow

Invoca este workflow cuando:

- Te enfrentes a un bug complejo que no se resuelva fácilmente con el depurador estándar.
- Tengas que tomar una decisión arquitectónica o de diseño (por ejemplo, Adapter Pattern frente a Hooks directos).
- Tengas dudas sobre una implementación específica y desees contrastar opiniones entre modelos avanzados de razonamiento.

---

## 2. Flujo de Obtención de Contexto y Análisis (Orden de Prioridad)

Antes de lanzar un debate o resolver una consulta técnica, el agente debe seguir estrictamente este orden para documentarse y capturar el contexto del proyecto de forma óptima:

1. **CodeGraph (Análisis Estructural):** Utiliza las herramientas de CodeGraph para descubrir dependencias, referencias estructurales y firmas de los símbolos y archivos involucrados.
2. **NotebookLM (Búsqueda Conceptual y Prácticas):** Consulta el cuaderno de NotebookLM `user-notebooklm-lovablefeatures` para asimilar el contexto funcional de negocio, reglas de negocio específicas y directrices/buenas prácticas de programación del proyecto.
3. **Debate de Modelos (OpenCode Go):** Si tras los pasos anteriores persiste una disyuntiva técnica o de diseño (como qué patrón aplicar), ejecuta el script de debate de modelos para contrastar alternativas.

## 3. Instrucciones de Ejecución del Script de Debate

Para iniciar el debate sobre una cuestión concreta o sobre un archivo en particular, ejecuta el script `debate-models.cjs` desde la raíz del proyecto usando `node`:

### Comando Estándar (Interrogar sobre una duda técnica)

Por defecto, el script interroga a `deepseek-v4-flash` y `qwen3.7-max` a través de los endpoints de OpenCode Go correspondientes:

```bash
node scripts/debate-models.cjs -q "¿Cómo optimizarías esta consulta SQL?"
```

### Comando con Modelos Específicos de OpenCode Go

Si deseas contrastar con otros modelos de Go (como `qwen3.7-plus`):

```bash
node scripts/debate-models.cjs -q "¿Cómo estructurarías este endpoint?" -b "qwen3.7-plus"
```

### Comando con Contexto de Archivo

Si quieres contrastar el diseño de un archivo específico (por ejemplo, `c:\GIT\vnapp-refactor\src\hooks\useExample.ts`):

```bash
node scripts/debate-models.cjs -f "src/hooks/useExample.ts" -q "¿Qué mejoras de tipado y manejo de errores recomiendas?"
```

---

## 4. Salida y Evaluación del Debate

1. El script invocará localmente al CLI de `opencode` en segundo plano mediante redirección de entrada estándar (`stdin < archivo_temporal`). Esto permite realizar consultas rápidas e inyectar archivos de contexto de forma **100% gratuita (Zero API Cost)**, utilizando la tarifa plana de tu plan de OpenCode Go.
2. Generará un reporte estructurado en formato markdown y lo guardará en `.gemini/debates/debate_<timestamp>.md`.
3. Lee este archivo generado para obtener los puntos de vista de ambos modelos de forma detallada.
4. Analiza las discrepancias, decide el mejor enfoque técnico conforme a las **Reglas del Proyecto** y documenta las conclusiones en tu respuesta al usuario.
