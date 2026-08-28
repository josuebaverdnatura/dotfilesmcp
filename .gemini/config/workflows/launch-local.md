# Arrancar Entorno Local

Este workflow se encarga de levantar tanto el ecosistema de **Supabase** (Base de datos, Auth, Edge Functions) como el **Frontend** (Vite).

## Pasos

1. Asegúrate de que **Docker Desktop** esté abierto y ejecutándose en tu ordenador.
2. Ejecuta el comando `npx supabase start` para levantar la infraestructura de Supabase local.
3. Ejecuta el comando `npm run dev` para levantar el servidor de desarrollo de Vite.
4. (Opcional) Si necesitas correr específicamente una Edge Function aislada para debug detallado fuera del entorno general, puedes usar `npx supabase functions serve <nombre-de-la-funcion>`.

> [!TIP]
> Puedes pedirme "Ejecuta el workflow de launch-local" o usar el comando `/launch-local` en el chat en el futuro y haré todo esto por ti automáticamente.
