<?php

namespace App\Providers;

use App\Domain\AnimalMovements\Models\AnimalMovement;
use App\Domain\AnimalMovements\Policies\AnimalMovementPolicy;
use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalGroup;
use App\Domain\AnimalRegistry\Policies\AnimalBreedPolicy;
use App\Domain\AnimalRegistry\Policies\AnimalGroupPolicy;
use App\Domain\AnimalRegistry\Policies\AnimalPolicy;
use App\Domain\AnimalWeights\Models\AnimalWeight;
use App\Domain\AnimalWeights\Policies\AnimalWeightPolicy;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        Gate::policy(AnimalMovement::class, AnimalMovementPolicy::class);
        Gate::policy(AnimalWeight::class, AnimalWeightPolicy::class);
        Gate::policy(AnimalBreed::class, AnimalBreedPolicy::class);
        Gate::policy(AnimalGroup::class, AnimalGroupPolicy::class);
        Gate::policy(Animal::class, AnimalPolicy::class);
        RateLimiter::for('login', fn (Request $request) => [
            Limit::perMinute(10)->by('identity:'.hash('sha256', strtolower((string) $request->input('email')))),
            Limit::perMinute(30)->by($request->ip()),
        ]);
        RateLimiter::for('renew', fn (Request $request) => Limit::perMinute(20)->by($request->ip()));
    }
}
