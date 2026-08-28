---
description: Levantar el entorno de desarrollo local (Frontend + instrucciones para Supabase)
---

Ejecuta el siguiente flujo para levantar el entorno local:

1. **Supabase Core (Docker):**
   - Si los contenedores no están activos, ejecuta `npx supabase start`.

2. **Entorno Completo Unificado (Recomendado):**
   - Ejecuta `npm run dev:all` para levantar simultáneamente en una sola terminal tanto las **Edge Functions** de Deno como el **Frontend** de Vite.

3. **O Ejecución Separada (Manual):**
   - **Terminal 1:** `npm run functions:serve` (o `npx supabase functions serve --env-file ./.env --no-verify-jwt`)
   - **Terminal 2:** `npm run dev`

4. **Notificación al Usuario:**
   - App disponible en `http://localhost:8080` y Edge Functions en `http://localhost:54321/functions/v1/`.
