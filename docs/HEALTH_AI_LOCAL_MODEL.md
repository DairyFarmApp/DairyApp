# Local animal-health language model

DairyCare uses deterministic, veterinarian-approved retrieval for clinical matching. The optional local model only rewrites retrieved facts into simple English and Roman Urdu. It never selects the disease, invents medicine, or creates a dose.

## Recommended local runtime

- Ollama
- `qwen2.5:7b-instruct` (about 4.7 GB download)
- Local endpoint `http://127.0.0.1:11434/v1`

Run from the repository root:

```powershell
.\scripts\setup-health-ai.ps1
```

Configure `apps/api/.env`:

```dotenv
HEALTH_AI_ENABLED=true
HEALTH_AI_URL=http://127.0.0.1:11434/v1
HEALTH_AI_MODEL=qwen2.5:7b-instruct
HEALTH_AI_TIMEOUT=30
```

Then run `php artisan config:clear` followed by `php artisan health-ai:evaluate --require-model --json`.

The command fails if a grounded scenario falls back to deterministic mode, a clinical expectation fails, citations disappear, or dose-like text is detected. Unsupported questions deliberately remain deterministic. Do not expose Ollama directly to farm devices or the public internet; Laravel is the only supported caller.
