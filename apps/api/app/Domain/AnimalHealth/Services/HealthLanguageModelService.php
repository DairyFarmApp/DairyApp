<?php

namespace App\Domain\AnimalHealth\Services;

use Illuminate\Support\Facades\Http;

class HealthLanguageModelService
{
    public function generate(string $question, string $language, array $primaryContext, ?array $animalContext): array
    {
        $provider = (string) config('services.health_ai.provider', 'openai_compatible');
        $system = 'Use only PRIMARY_CONTEXT for the current possible condition. RECORDED_HISTORY is factual background only; never treat an old condition as a current diagnosis. Never prescribe, name a new medicine, repeat an old dose as advice, invent a dose, or add a home remedy not present in PRIMARY_CONTEXT. Return one JSON object with only answer_en in 1 or 2 short sentences.';
        $prompt = "QUESTION: $question\nLANGUAGE: $language\nRECORDED_HISTORY: ".json_encode($animalContext, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES)."\nPRIMARY_CONTEXT: ".json_encode($primaryContext, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        return match ($provider) {
            'gemini' => $this->generateWithGemini($system, $prompt),
            'openai_compatible' => $this->generateWithOpenAiCompatible($system, $prompt),
            default => throw new \InvalidArgumentException("Unsupported health AI provider [$provider]."),
        };
    }

    private function generateWithOpenAiCompatible(string $system, string $prompt): array
    {
        $payload = [
            'model' => config('services.health_ai.model'),
            'temperature' => 0,
            'max_tokens' => 128,
            'response_format' => ['type' => 'json_object'],
            'messages' => [
                ['role' => 'system', 'content' => $system],
                ['role' => 'user', 'content' => $prompt],
            ],
        ];
        $content = Http::timeout((int) config('services.health_ai.timeout', 15))
            ->post(rtrim((string) config('services.health_ai.url'), '/').'/chat/completions', $payload)
            ->throw()
            ->json('choices.0.message.content');

        return $this->decodeJson($content);
    }

    private function generateWithGemini(string $system, string $prompt): array
    {
        $apiKey = (string) config('services.health_ai.api_key');
        if ($apiKey === '') {
            throw new \RuntimeException('GEMINI_API_KEY is not configured.');
        }
        $model = rawurlencode((string) config('services.health_ai.model'));
        $url = rtrim((string) config('services.health_ai.url'), '/').'/models/'.$model.':generateContent';
        $payload = [
            'systemInstruction' => ['parts' => [['text' => $system]]],
            'contents' => [['role' => 'user', 'parts' => [['text' => $prompt]]]],
            'generationConfig' => [
                'temperature' => 0,
                'maxOutputTokens' => 160,
                'responseMimeType' => 'application/json',
                'responseJsonSchema' => [
                    'type' => 'object',
                    'properties' => ['answer_en' => ['type' => 'string']],
                    'required' => ['answer_en'],
                    'additionalProperties' => false,
                ],
            ],
        ];
        $content = Http::timeout((int) config('services.health_ai.timeout', 15))
            ->withHeaders(['x-goog-api-key' => $apiKey])
            ->post($url, $payload)
            ->throw()
            ->json('candidates.0.content.parts.0.text');

        return $this->decodeJson($content);
    }

    private function decodeJson(mixed $content): array
    {
        if (! is_string($content)) {
            throw new \JsonException('The language model did not return text content.');
        }
        $start = strpos($content, '{');
        $end = strrpos($content, '}');
        if ($start === false || $end === false || $end < $start) {
            throw new \JsonException('The language model did not return a complete JSON object.');
        }
        $decoded = json_decode(substr($content, $start, $end - $start + 1), true, flags: JSON_THROW_ON_ERROR);
        if (! is_array($decoded)) {
            throw new \JsonException('The language model JSON response must be an object.');
        }

        return $decoded;
    }
}
