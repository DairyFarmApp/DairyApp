<?php

namespace App\Domain\AnimalRegistry\Support;

use App\Domain\AnimalRegistry\Models\AnimalBreed;
use App\Domain\AnimalRegistry\Models\AnimalSpecies;
use App\Models\Organization;
use App\Models\User;

final class DefaultAnimalBreedCatalog
{
    /**
     * @var array<string, array{name: string, breeds: array<string, string>}>
     */
    private const CATALOG = [
        'CATTLE' => [
            'name' => 'Cattle',
            'breeds' => [
                'HOLSTEIN-FRIESIAN' => 'Holstein Friesian',
                'JERSEY' => 'Jersey',
                'SAHIWAL' => 'Sahiwal',
                'RED-SINDHI' => 'Red Sindhi',
                'THARPARKAR' => 'Tharparkar',
                'CHOLISTANI' => 'Cholistani',
                'DHANNI' => 'Dhanni',
                'CATTLE-CROSSBRED' => 'Cattle Crossbred',
            ],
        ],
        'BUFFALO' => [
            'name' => 'Buffalo',
            'breeds' => [
                'NILI-RAVI' => 'Nili-Ravi',
                'KUNDI' => 'Kundi',
                'AZI-KHELI' => 'Azi Kheli',
                'BUFFALO-CROSSBRED' => 'Buffalo Crossbred',
            ],
        ],
    ];

    public function __construct(private readonly AnimalRegistryNormalizer $normalizer) {}

    public function ensureForOrganization(Organization $organization, ?User $actor = null): void
    {
        foreach (self::CATALOG as $speciesCode => $definition) {
            $species = AnimalSpecies::query()->firstOrCreate(
                ['code' => $speciesCode],
                ['name' => $definition['name'], 'is_active' => true],
            );

            foreach ($definition['breeds'] as $code => $name) {
                AnimalBreed::query()->firstOrCreate(
                    [
                        'organization_id' => $organization->id,
                        'species_id' => $species->id,
                        'code' => $code,
                    ],
                    [
                        'name' => $name,
                        'normalized_name' => $this->normalizer->name($name),
                        'description' => 'Built-in DairyCare breed option.',
                        'is_active' => true,
                        'created_by' => $actor?->id,
                        'updated_by' => $actor?->id,
                    ],
                );
            }
        }
    }
}
