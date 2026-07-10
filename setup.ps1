# Dotfiles Stack IA - Setup Script
# Configura automáticamente el stack de IA agéntica

param(
    [switch]$SkipDependencies,
    [switch]$SkipOllama
)

$ErrorActionPreference = "Stop"

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Text)
    Write-Host "→ $Text" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Text)
    Write-Host "✓ $Text" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Text)
    Write-Host "⚠ $Text" -ForegroundColor Yellow
}

function Read-Input {
    param(
        [string]$Prompt,
        [string]$Default = "",
        [switch]$Secure
    )

    $displayPrompt = if ($Default) { "$Prompt [$Default]" } else { $Prompt }

    if ($Secure) {
        $value = Read-Host $displayPrompt -AsSecureString
        if ($value.Length -eq 0 -and $Default) { return $Default }
        return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($value))
    } else {
        $value = Read-Host $displayPrompt
        if ([string]::IsNullOrWhiteSpace($value)) { return $Default }
        return $value
    }
}

# Banner
Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
Write-Host "║                                                               ║" -ForegroundColor Magenta
Write-Host "║         Dotfiles Stack IA - Configurador Interactivo          ║" -ForegroundColor Magenta
Write-Host "║                                                               ║" -ForegroundColor Magenta
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
Write-Host ""
Write-Host "Este script configurará:" -ForegroundColor White
Write-Host "  • Gemini CLI (config, MCP servers)" -ForegroundColor Gray
Write-Host "  • Antigravity IDE (settings)" -ForegroundColor Gray
Write-Host "  • opencode, notebooklm-mcp" -ForegroundColor Gray
Write-Host "  • Git config" -ForegroundColor Gray
Write-Host ""

# Recopilar información
Write-Header "Configuración Básica"

$gitName = Read-Input "Nombre para Git" "Tu Nombre"
$gitEmail = Read-Input "Email para Git" "tu@email.com"

Write-Header "Tokens y API Keys (opcional - Enter para omitir)"

Write-Host "GitHub Personal Access Token (para MCP server):" -ForegroundColor Gray
Write-Host "  Crear en: https://github.com/settings/tokens" -ForegroundColor DarkGray
$githubToken = Read-Input "GitHub Token" "" -Secure

Write-Host ""
Write-Host "Supabase Keys (para MCP server local):" -ForegroundColor Gray
$supabaseServiceKey = Read-Input "Supabase Service Role Key" "" -Secure
$supabaseAccessToken = Read-Input "Supabase Access Token" "" -Secure

Write-Header "NotebookLM MCP (opcional)"

Write-Host "Cookies de Google para NotebookLM MCP:" -ForegroundColor Gray
Write-Host "  Extraer desde DevTools → Application → Cookies en notebooklm.google.com" -ForegroundColor DarkGray
$setupNotebookLM = Read-Input "¿Configurar NotebookLM? (s/N)" "N"

$cookies = @{}
if ($setupNotebookLM -match "^[sSyY]") {
    $cookieNames = @("__Secure-1PSIDCC", "SIDCC", "SID", "HSID", "SSID", "APISID", "SAPISID")
    foreach ($cookie in $cookieNames) {
        $cookies[$cookie] = Read-Input "Cookie $cookie" "" -Secure
    }
}

# Procesar configuración
Write-Header "Instalando Configuración"

# 1. Git config
Write-Step "Configurando Git..."
$gitconfigContent = @"
[user]
    name = $gitName
    email = $gitEmail
[core]
    autocrlf = true
    editor = code --wait
[init]
    defaultBranch = main
[push]
    default = simple
"@
$gitconfigContent | Out-File -FilePath "$env:USERPROFILE\.gitconfig" -Encoding UTF8 -Force
Write-Success "Git config instalado"

# 2. WSL config
Write-Step "Copiando WSL config..."
Copy-Item -Path ".\.wslconfig" -Destination "$env:USERPROFILE\.wslconfig" -Force
Write-Success "WSL config copiado"

# 3. Gemini config
Write-Step "Configurando Gemini CLI..."
$geminiDir = "$env:USERPROFILE\.gemini"
if (!(Test-Path $geminiDir)) { New-Item -ItemType Directory -Path $geminiDir -Force | Out-Null }

Copy-Item -Path ".\.gemini\config" -Destination $geminiDir -Recurse -Force

# Procesar MCP config template
$mcpTemplate = Get-Content ".\.gemini\config\mcp_config.template.json" -Raw
$mcpTemplate = $mcpTemplate -replace '<tu-token-github>', $githubToken
$mcpTemplate = $mcpTemplate -replace '<tu-service-role-key>', $supabaseServiceKey
$mcpTemplate = $mcpTemplate -replace '<tu-access-token>', $supabaseAccessToken

$mcpTemplate | Out-File -FilePath "$geminiDir\config\mcp_config.json" -Encoding UTF8 -Force
Write-Success "Gemini config instalado"

# 4. Antigravity IDE
Write-Step "Configurando Antigravity IDE..."
$antigravityDir = "$env:APPDATA\Antigravity IDE\User"
if (!(Test-Path $antigravityDir)) { New-Item -ItemType Directory -Path $antigravityDir -Force | Out-Null }

Copy-Item -Path ".\Antigravity IDE\User\settings.json" -Destination $antigravityDir -Force
Write-Success "Antigravity IDE settings copiados"

# 5. opencode
Write-Step "Configurando opencode..."
$opencodeDir = "$env:USERPROFILE\.config\opencode"
if (!(Test-Path $opencodeDir)) { New-Item -ItemType Directory -Path $opencodeDir -Force | Out-Null }

Copy-Item -Path ".\opencode\opencode.jsonc" -Destination $opencodeDir -Force
Write-Success "opencode config copiado"

# 6. NotebookLM MCP
if ($cookies.Count -gt 0) {
    Write-Step "Configurando NotebookLM MCP..."
    $notebooklmDir = "$env:USERPROFILE\.notebooklm-mcp"
    if (!(Test-Path $notebooklmDir)) { New-Item -ItemType Directory -Path $notebooklmDir -Force | Out-Null }

    $authJson = @{
        cookies = $cookies
        userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    } | ConvertTo-Json -Depth 3

    $authJson | Out-File -FilePath "$notebooklmDir\auth.json" -Encoding UTF8 -Force
    Write-Success "NotebookLM MCP configurado"
}

# Dependencias
if (!$SkipDependencies) {
    Write-Header "Dependencias"

    $installDeps = Read-Input "¿Instalar dependencias npm globales? (S/n)" "S"
    if ($installDeps -notmatch "^[nN]") {
        Write-Step "Instalando MCP servers..."
        npm install -g @modelcontextprotocol/server-github
        npm install -g @supabase/mcp-server-supabase
        Write-Success "MCP servers instalados"
    }
}

# Ollama
if (!$SkipOllama) {
    Write-Header "Modelos Ollama"

    if (Get-Command ollama -ErrorAction SilentlyContinue) {
        $installOllama = Read-Input "¿Descargar modelos Ollama (hermes3:8b, qwen2.5-coder:7b)? (S/n)" "S"
        if ($installOllama -notmatch "^[nN]") {
            Write-Step "Descargando hermes3:8b..."
            ollama pull hermes3:8b
            Write-Step "Descargando qwen2.5-coder:7b..."
            ollama pull qwen2.5-coder:7b
            Write-Success "Modelos Ollama descargados"
        }
    } else {
        Write-Warning "Ollama no está instalado. Descárgalo de https://ollama.ai"
    }
}

# Resumen final
Write-Header "Setup Completado"

Write-Host "Configuración instalada:" -ForegroundColor Green
Write-Host "  ✓ Git config ($gitName <$gitEmail>)" -ForegroundColor Gray
Write-Host "  ✓ Gemini CLI + MCP servers" -ForegroundColor Gray
Write-Host "  ✓ Antigravity IDE settings" -ForegroundColor Gray
Write-Host "  ✓ opencode config" -ForegroundColor Gray
if ($cookies.Count -gt 0) {
    Write-Host "  ✓ NotebookLM MCP" -ForegroundColor Gray
}

Write-Host ""
Write-Host "Próximos pasos:" -ForegroundColor Yellow
Write-Host "  1. Reinicia tu terminal para aplicar cambios" -ForegroundColor Gray
Write-Host "  2. Ejecuta 'gemini' para iniciar Gemini CLI" -ForegroundColor Gray
Write-Host "  3. Abre Antigravity IDE y verifica los settings" -ForegroundColor Gray
Write-Host ""

if ([string]::IsNullOrWhiteSpace($githubToken) -or [string]::IsNullOrWhiteSpace($supabaseServiceKey)) {
    Write-Warning "Algunos tokens quedaron vacíos. Edita manualmente:"
    Write-Host "  $geminiDir\config\mcp_config.json" -ForegroundColor Gray
}

Write-Host ""
