# Local animal-health language model

DairyCare uses deterministic, veterinarian-approved retrieval for clinical matching. The optional local model only rewrites retrieved facts into simple English and Roman Urdu. It never selects the disease, invents medicine, or creates a dose.

## Gemini provider

Gemini can replace the local rewriting model while the same deterministic matching, reviewed evidence, output validation, and outage fallback remain in force. Put the key only in the Laravel server environment; never include it in the Flutter application or APK.

```dotenv
HEALTH_AI_ENABLED=true
HEALTH_AI_PROVIDER=gemini
HEALTH_AI_URL=https://generativelanguage.googleapis.com/v1beta
HEALTH_AI_MODEL=gemini-2.5-flash
GEMINI_API_KEY=your-server-side-key
HEALTH_AI_TIMEOUT=30
```

Run `php artisan config:clear` after changing these values. Gemini receives the farmer's question, the selected animal's limited clinical history, and only the top retrieved approved condition. It may simplify that evidence but cannot introduce a medicine, dose, diagnosis, or home remedy. If the key, service, response schema, or safety validation fails, DairyCare automatically returns deterministic reviewed guidance.

## Recommended local runtime

- Ollama
- `qwen2.5:7b-instruct` (about 4.7 GB download)
- Local endpoint `http://127.0.0.1:11434/v1`

On CPU-only hardware where the 7B model cannot answer inside the configured
timeout, `qwen2.5:1.5b-instruct` is the verified fallback. DairyCare lets the
local model simplify the English answer and retains veterinarian-reviewed
Roman Urdu from the approved dataset. On the validation workstation this model
passed all 26 required scenarios in about 2.5 minutes; the 7B model timed out.

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

## Clarification conversations

The API does not force a disease match from vague or overlapping signs. It
returns `mode: clarification` with no disease matches and asks one short,
controlled English/Roman Urdu question. Current targeted branches include
fever, respiratory signs, tick-borne signs, diarrhea, skin signs, and hoof
problems. The Flutter chat sends recent messages as context, so the farmer can
answer naturally without repeating the animal type or earlier signs.

Distinctive key signs can resolve the differential on a later message. For
example, `ticks + fever` asks about urine colour; a reply of `peshab laal hai`
retains the earlier context and can retrieve babesiosis guidance. Emergency
deterioration such as inability to stand bypasses clarification and escalates
immediately. New diseases must include overlap tests before release.

## Animal-linked conversations

The assistant can optionally receive an `animal_id`. Laravel verifies that the
animal belongs to the authenticated organization and active farm, then loads
up to five recent health cases and five recorded treatments. This history is
passed to the local model as factual background and returned as
`animal_context`; it is never used as proof that an old condition is active.

Only treatment-ledger entries are treated as medicines actually administered.
AI suggestions and chat text do not create treatment records, consume stock,
or establish milk/meat withdrawal periods. Those effects remain in the
veterinarian-controlled treatment workflow.
