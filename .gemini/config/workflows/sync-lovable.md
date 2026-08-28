---
description: Sincronizar rama V2 (Lovable) manteniendo El Santuario y aplicando patrones Strangler Fig / Decorator / Adapter
---

Por favor, inicia el flujo de integración continua para sincronizar los últimos cambios generados por la plataforma Lovable hacia nuestra arquitectura limpia.

Sigue EXTREMADAMENTE ESTRICTO este procedimiento paso a paso:

1. **Preparación:**

- Asegúrate de estar en un espacio de trabajo limpio (`git status`).
- Haz un checkout a `main` y actualízalo con `git pull origin main` (desde Gitea).
- Trae los cambios remotos de Lovable: `git fetch github V2` (desde GitHub).

2. **Creación de Rama Intermedia:**

- Crea una nueva rama a partir de `main` con la nomenclatura `sync/lovable-YYYY-MM-DD` (usa la fecha de hoy).
- Haz checkout a esa nueva rama.

3. **Fusión y Protección de "El Santuario" (CRÍTICO):**

- Ejecuta el merge: `git merge github/V2`.
- **Regla de Hierro de El Santuario:**
  - **Lovable Territory:** `src/pages/`, `src/components/`, `src/App.tsx`.
  - **El Santuario (Protegido):** `src/modules/`, `src/hooks/`, `src/lib/`, `supabase/functions/`.
  - Si el merge modifica o causa conflictos en archivos dentro de El Santuario, **mantén siempre nuestra versión limpia de `main`** (`git checkout --ours src/modules/ src/hooks/ src/lib/ supabase/functions/`).
  - Bajo ninguna circunstancia permitas que el código crudo generado por Lovable sobreescriba o desestabilice la lógica modular del Santuario.

4. **Scouting de Novedades Estructurales y Auditoría de Entry-Points (Cero Vistas Huérfanas):**

- **Scouting de Diff:** Ejecuta `git diff --name-status main...github/V2` para identificar todas las carpetas, nuevos sub-hubs, componentes y vistas incorporadas en `src/components/` o `src/pages/`.
- **Auditoría de Entry-Points:** Inspecciona `src/pages/AdminControlPanel.tsx`, `src/pages/ControlIncidencias.tsx` y `src/App.tsx`. Comprueba que los contenedores de página consuman los nuevos componentes visuales de `src/components/` en lugar de apuntar a versiones monolíticas legadas.
- **Patrón Adapter / Strangler Fig:**
  - Conecta los nuevos componentes visuales de Lovable a los Custom Hooks y servicios modulares de `src/modules/` mediante adaptadores, manteniendo la UI reactiva y la lógica de negocio desacoplada.

5. **Validación Determinista Fail-Fast (3 Niveles Obligatorios):**

- **Nivel 1 (Typechecking):** `npx tsc --noEmit`
- **Nivel 2 (Resolución de Bundler):** `npm run build`
- **Nivel 3 (Runtime Console Audit Playwright):** `npm run test:console` (con sesión autenticada de administrador, auditando el 100% de rutas y sub-pestañas).
- **Escaneo Local SonarQube:** `npm run sonar` (exigir Quality Gate **PASS / OK**).

6. **Pull Request y Sincronización en Obsidian:**

- Haz push de la rama intermedia: `git push -u origin <nombre-de-la-rama>`.
- Crea la PR apuntando hacia `main` en Gitea/GitHub con el título `chore: sincronización con Lovable V2 [Fecha]`.
- Actualiza los documentos en `docs_md/` y replícalos a la par en la bóveda de Obsidian (`\\server\josueba\Obsidian\josuebaverdnatura\Proyectos\VerdNatura\vnapp-refactor-files-docs\`).
- Registra el avance en `\\server\josueba\Obsidian\josuebaverdnatura\Proyectos\VerdNatura\Historico_Peticiones.md`.
- Si aplica, sincroniza la base de conocimiento subiendo los docs a NotebookLM (`notebook upload docs`).ejecuta `notebook cleanup` si necesitas destrabar procesos de Chrome).

