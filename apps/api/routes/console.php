<?php

use App\Domain\AnimalHealth\Services\HealthAiEvaluationService;
use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('health-ai:evaluate {--json : Print the complete machine-readable report} {--require-model : Fail unless the configured local model phrases every grounded scenario}', function (HealthAiEvaluationService $evaluator): int {
    if ($this->option('require-model') && ! config('services.health_ai.enabled')) {
        $this->error('HEALTH_AI_ENABLED must be true for a model-required benchmark.');

        return self::FAILURE;
    }
    $report = $evaluator->evaluate((bool) $this->option('require-model'));

    if ($this->option('json')) {
        $this->line(json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));
    } else {
        $this->info('DairyCare animal health AI evaluation');
        $this->table(
            ['Metric', 'Score'],
            collect($report['metrics'])->map(fn (float $value, string $name): array => [$name, number_format($value * 100, 2).'%'])->values()->all(),
        );
        $this->line("Scenarios: {$report['passed_scenario_count']}/{$report['scenario_count']} passed");
    }

    if (! $report['release_gate_passed']) {
        $this->error('Release gate failed. Review the failed veterinary evaluation scenarios.');

        return self::FAILURE;
    }

    $this->info('Release gate passed.');

    return self::SUCCESS;
})->purpose('Evaluate grounded animal-health guidance against approved bilingual veterinary cases');
