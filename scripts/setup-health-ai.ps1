param([string]$Model = 'qwen2.5:7b-instruct', [switch]$SkipPull)
$ErrorActionPreference = 'Stop'
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { throw 'Ollama is not installed or is not on PATH. Install it from https://ollama.com/download' }
if (-not $SkipPull) { & ollama pull $Model; if ($LASTEXITCODE -ne 0) { throw "Ollama could not pull $Model" } }
$models = Invoke-RestMethod -Uri 'http://127.0.0.1:11434/api/tags' -Method Get
if (-not ($models.models.name -contains $Model)) { throw "Configured model $Model is not available in Ollama." }
Write-Host "Ollama model ready: $Model"
Write-Host 'Set HEALTH_AI_ENABLED=true, HEALTH_AI_URL=http://127.0.0.1:11434/v1, and HEALTH_AI_MODEL to this model.'
Write-Host 'Then run: php artisan health-ai:evaluate --require-model'
