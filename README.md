# Dotfiles — Stack de IA Agéntica

Stack completo de herramientas de IA agéntica: Gemini CLI, Antigravity IDE, MCP servers, Supabase local.

## Stack incluido

- **Gemini CLI** — agente IA con MCP, conocimiento (brain), conversaciones
- **Antigravity IDE** — IDE basado en VS Code con extensiones y settings
- **Supabase** — backend local (PostgreSQL, auth, storage, realtime)
- **MCP Servers**: GitHub, Supabase, NotebookLM, Codegraph
- **NotebookLM MCP** — integración con Google NotebookLM
- **Ollama** — LLMs locales (hermes3:8b, qwen2.5-coder:7b)
- **opencode** — CLI de código asistido por IA

## Setup rápido

### Setup automatizado (recomendado)

```powershell
# Clonar el repo
git clone https://github.com/josuebaverdnatura/dotfilesmcp.git
cd dotfilesmcp

# Ejecutar setup interactivo
.\setup.ps1

# Opciones avanzadas
.\setup.ps1 -SkipDependencies    # Sin instalar npm packages
.\setup.ps1 -SkipOllama          # Sin descargar modelos Ollama
```

El script te pedirá interactivamente:
- Nombre y email para Git
- GitHub Personal Access Token
- Supabase keys (Service Role Key, Access Token)
- Cookies de NotebookLM (opcional)

### Setup manual

### 1. Instalar dependencias base

```powershell
# Node.js (LTS) — https://nodejs.org
# Ollama — https://ollama.ai
# Docker Desktop — https://docker.com

# Modelos Ollama
ollama pull hermes3:8b
ollama pull qwen2.5-coder:7b

# CLI tools
npm install -g @modelcontextprotocol/server-github
npm install -g @supabase/mcp-server-supabase
npx -y notebooklm-mcp@latest
```

### 2. Configurar Gemini CLI

```powershell
# Copiar config de Gemini
copy-item -Path ".\gemini\config" -Destination "$env:USERPROFILE\.gemini\" -Recurse -Force

# Editar MCP config con tus tokens:
# $env:USERPROFILE\.gemini\config\mcp_config.json
#   - GITHUB_PERSONAL_ACCESS_TOKEN: tu token de GitHub
#   - SUPABASE_SERVICE_ROLE_KEY: tu key de Supabase
#   - SUPABASE_ACCESS_TOKEN: tu token de Supabase

# Editar AGENTS.md con tus proyectos
```

### 3. Antigravity IDE

```powershell
# Copiar settings
copy-item -Path ".\Antigravity IDE\User\settings.json" -Destination "$env:APPDATA\Antigravity IDE\User\" -Force

# Instalar extensiones desde _extensions_list.txt
```

### 4. Configuración de línea de comandos

```powershell
# Copiar configs base
copy-item .gitconfig "$env:USERPROFILE\.gitconfig"
copy-item .wslconfig "$env:USERPROFILE\.wslconfig"
```

### 5. Supabase local

```powershell
# Iniciar proyecto Supabase
cd proyectos/mi-proyecto
supabase init
supabase start

# Cargar dump si existe
docker exec -i supabase_db_... psql -U postgres < dump.sql
```

## Archivos sensibles (NO versionar)

- `.gemini\config\mcp_config.json` — contiene API keys y tokens
- `.ssh\` — claves privadas SSH
- `notebooklm-mcp\auth.json` — sesión de Google
- Cualquier `.env` con secrets

## Estructura

```
dotfiles\
├── README.md
├── .gitconfig
├── .wslconfig
├── .gemini\
│   └── config\
│       ├── AGENTS.md           # Reglas del agente IA
│       ├── config.json          # Permisos y settings
│       ├── mcp_config.json      # Template MCP (sin keys)
│       └── projects\            # Proyectos del agente
├── Antigravity IDE\
│   └── User\
│       ├── settings.json
│       ├── snippets\
│       └── workspaceStorage\
├── notebooklm-mcp\
│   └── auth_template.json
├── opencode\
│   └── opencode.jsonc
├── claude\
└── projects\                    # Referencia a proyectos
```

## Referencia rápida

```powershell
# Gemini CLI
gemini                     # Iniciar sesión interactiva
gemini --task "..."        # Tarea directa
gemini --model hermes3:8b  # Usar modelo local

# Supabase
supabase status            # Ver estado
supabase db dump           # Exportar DB
supabase stop              # Parar servicios

# Ollama
ollama list                # Ver modelos
ollama pull <modelo>       # Descargar modelo

# Docker
docker ps                  # Ver contenedores
docker compose down        # Parar servicios
```
