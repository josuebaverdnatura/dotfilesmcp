---
description: Limpiar deuda técnica SonarQube (Francotirador Autónomo)
---

Por favor, inicia el protocolo de limpieza de deuda técnica en modo **Francotirador Autónomo**.

Sigue EXTREMADAMENTE ESTRICTO este procedimiento paso a paso:

1. **Preparación del Entorno:**

- Verifica que `SONAR_TOKEN` esté configurado en `.env` (gitignoreado). Si falta, aborta y pide al usuario que lo copie de `.env.example`.
- Asegúrate de que `git status` esté limpio (sin archivos modificados fuera de `scratch/`). Si hay cambios pendientes, pausa y avisa.
- Carga el skill completo desde `.opencode/skills/improve-sonar/SKILL.md` para acceder a las heurísticas SWE extendidas y la lista negra de anti-overfitting.

2. **Scouting Inicial:**

- Ejecuta silenciosamente: `node scratch/get_sonar_issues.js --territory=sanctuary --limit=10`
- Parsea el JSON de salida. Si `totalQueued === 0`, salta al paso 8 (dashboard final).
- La cola persistente se guarda en `scratch/sonar_queue.json`.

3. **Loop Autónomo (máximo 10 iteraciones):**

Para cada issue en la cola:

a. **Pop del siguiente issue:** Usa `popNext()` desde `scratch/sonar_queue.js` para reservar atomically el issue y moverlo a `inProgress`. Logea `phase: "scouting"` con `logEvent` desde `scratch/sonar_log.js`.

b. **Gate de Territorio:** Si `issue.territory === "lovable"`, ejecuta `markSkipped(issueKey, "lovable-territory")`, logea `phase: "skipped"`, y continúa con el siguiente. **NO mutar nunca** `src/pages/`, `src/components/ui/`, `src/App.tsx` (AGENTS.md §4).

c. **Análisis Arquitectónico con CodeGraph:** Antes de tocar el símbolo, llama `codegraph_explore` con:
   - El nombre del símbolo (si es derivable del mensaje) o el archivo + la línea del issue.
   - Inspecciona el **blast radius** (callers + dependientes) que codegraph devuelve.
   - Verifica si existe test que cubre el símbolo. Si no existe, incluye como tarea pendiente escribir/actualizar el test (gate de cobertura 80% en código nuevo, AGENTS.md §2).

d. **Resolución mediante Heurísticas SWE:** Aplica las 11 heurísticas obligatorias del skill (early return, SRP, DRY, magic numbers → constantes, DI para servicios externos, tipado estricto sin `any`, etc.). Prohibido parches baratos (NOSONAR, @ts-ignore, try/catch vacío, renombrado ofuscador).

e. **Sufijo de Hierro (secuencia de sensores en orden):**
   1. `npx tsc --noEmit` — gate de tipos.
   2. `npx eslint --quiet <archivos editados>` — linter estricto.
   3. `npm run test:coverage` — gate de cobertura unitaria.
   4. `npx ts-node scratch/e2e_console_audit.ts` — auditoría E2E de consola y excepciones React en tiempo de ejecución (Playwright).
   5. `npm run sonar` — escaneo local completo SonarQube.
   6. `node scratch/verify_fix.js <issueKey> --file=<file> --since=<ISO>` — verificación por issueKey + delta de regression + Quality Gate.

f. **Validación y Auto-Corrección (siguiendo `.agents/loops/bounded_loop_protocol.md`):**
   - Si `verify_fix.js` sale con `exit !== 0`, ejecuta el loop de auto-corrección: hasta 3 intentos antes de revertir.
   - Tras cada intento fallido, re-analiza con `codegraph_explore` el símbolo editado y corrige de raíz (no parchear el mensaje). Logea `phase: "fix-attempt", attempt: n, error` en `scratch/sonar_fix_log.jsonl`.
   - Tras 3 intentos fallidos: `git restore <archivos editados>` (revert automático), `requeue(issueKey)`, logea `phase: "reverted"`, y continúa con el siguiente issue.

g. **Reindex SonarQube lag:**
   - SonarQube tarda ~10-30s en reindexar. Espera con un poll: reintentar `verify_fix` cada 30s hasta 3 veces.
   - Si sigue flaky tras 90s y el código es correcto (sensors verdes), abre `phase: "verified"` con `qgSkipped: true` y deja el issue en `inProgress` (no marcar done).

h. **Cerrar issue en cola:**
   - `markDone(issueKey, { fixCommit, regressionDelta })`. Logea `phase: "verified"`.

i. **Checkpoint commit (opcional, cada 5 fixes):**
   - `git add <archivos editados> && git commit -m "refactor(sonar): batch N — <rules touched>"`.
   - **NO pushear** salvo orden explícita del usuario.

4. **Dashboard Final:**

Tras agotar iteraciones o vaciar la cola, emite un resumen compacto:

```
/improve-sonar DASHBOARD
Total antes  : <scouting anterior>
Total ahora  : <scouting current>
Fixed        : <done.length en sonar_queue.json>
Reverted     : <fix-attempt con phase:reverted en sonar_fix_log.jsonl>
Skipped      : <skipped.length> (territorio Lovable / false-positive)
Blocking     : <inProgress.length> (issues puestos en sigma por reindex lag)
Quality Gate : <OK | ERROR | skipped>

Top 5 reglas restantes:
  <rule>: <count>
```

5. **Casos Especiales:**

- **False positive confirmado:** `markSkipped(issueKey, "false-positive")` y abrir issue en SonarQube web UI marcando "False positive" para que no resurja.
- **Issue en archivo en `sonar.exclusions`** (p.ej. `supabase/functions/admin-operations/**`): skipped automáticamente por el territorio-neutral. Marcar skipped con razón `excluded-from-scan`.
- **Issue crítico (VULNERABILITY/BLOCKER)** que requiera cambiar la arquitectura de seguridad: pausa el loop autónomo, abre el plan y espera aprobación humana (per AGENTS.md §6 RDD).

6. **Reglas de Nombrado de Commits (sólo cuando el usuario lo pida):**

- Unitario: `refactor(sonar): <rule> en <archivo>` (p.ej. `refactor(sonar): S1541 cognitive-complexity en jornadas-handler`).
- Batch: `refactor(sonar): batch N — <reglas>` (sin push salvo orden).
- Nunca `fix:` para cierre de code smells: el cambio no es bugfix funcional.

---

**Recursos del Workflow:**
- Scouting: `scratch/get_sonar_issues.js`
- Cola persistente: `scratch/sonar_queue.js`
- Verificación: `scratch/verify_fix.js`
- Log de auditoría: `scratch/sonar_log.js` (append-only JSONL en `scratch/sonar_fix_log.jsonl`)
- Runner SonarQube: `scratch/sonar_run.js` (token desde env, nunca hardcoded)
- Skill completo: `.opencode/skills/improve-sonar/SKILL.md`
