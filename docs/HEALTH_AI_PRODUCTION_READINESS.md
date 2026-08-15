# Animal health AI production readiness

## Safety boundary

DairyCare is decision support, not autonomous diagnosis or prescribing. Deterministic retrieval selects only active, veterinarian-approved, species-scoped knowledge. The optional local model may simplify that retrieved text into English and Roman Urdu; it cannot select diseases, add medicine, or create a dose.

## Security and privacy controls

- All endpoints require an opaque authenticated session, active organization, and explicit permission.
- Health questions are limited to 12 requests per minute per session and 60 per minute per IP.
- Farmer questions are not written to application logs or audit logs. Audits retain species, selected symptom codes, response mode, and matched knowledge codes.
- Model failure logs contain the model identifier and exception class only.
- Ollama must listen on localhost or a private service network. Never expose port 11434 to farm devices or the public internet.
- Laravel is the sole supported model caller. Production API traffic must use HTTPS.

## Clinical governance

- Disease knowledge and bilingual evaluation cases require signed veterinary review.
- Pakistan medicine evidence requires a DRAP record and a separate veterinarian approval.
- DRAP listing is regulatory evidence, not treatment advice.
- Medicine evidence contains no generated dose. The current product label and veterinarian determine product choice, dose, route, duration, contraindications, and milk/meat withdrawal.
- Signed decisions retain immutable history, reviewer identity, registration number, notes, timestamp, audit log, and version.

## Release gates

Run before every health-AI production release:

```powershell
cd apps/api
php artisan test
php artisan health-ai:evaluate --json
php artisan health-ai:evaluate --require-model --json
```

The model-required gate must be executed on the actual deployment hardware with the configured Ollama model. Do not enable local-model phrasing in production if this gate fails.

## Operational monitoring

- Alert on repeated `Health AI local model unavailable` warnings.
- Deterministic fallback is expected during a short model outage and must remain available.
- Re-run veterinary review when knowledge, translations, symptom weights, model, prompt, or medicine evidence changes.
- Review DRAP evidence and product recalls before relying on availability information.
- Back up health knowledge, reviews, audit logs, and medicine evidence with the main database.

## Known limitations

- Current benchmark: 13 approved clinical cases and 26 bilingual scenarios. Expand before broad clinical rollout.
- Roman Urdu spelling varies; selected symptom codes are more reliable than free text alone.
- The system does not replace physical examination, laboratory confirmation, a prescription, or emergency veterinary services.
- Real-model performance depends on local hardware and must be measured after Ollama installation.
