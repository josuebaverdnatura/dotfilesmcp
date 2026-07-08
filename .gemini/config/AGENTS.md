<RULE[read-only-legacy-projects.md]>
### Regla: Proyectos Legacy de Solo Lectura

**Propósito**: Proteger los repositorios legacy de modificaciones accidentales, asegurando que actúan estrictamente como fuentes de conocimiento (Read-Only) para generar documentación y analizar código antiguo.

**Restricciones Obligatorias**:
1. **Cero Ediciones**: NUNCA editar, crear, borrar ni modificar archivos dentro de las carpetas de proyectos legacy.
2. **Cero Commits**: NUNCA ejecutar comandos como `git add`, `git commit` o `git push` en estos repositorios.
3. **Solo Extracción**: Estos proyectos solo pueden ser analizados mediante herramientas de lectura o mediante ejecución de scripts externos que extraigan información hacia otros proyectos.
4. **Actualizaciones Externas**: Para recibir cambios, el agente solo tiene permitido ejecutar `git pull` o `git fetch`.
</RULE[read-only-legacy-projects.md]>
