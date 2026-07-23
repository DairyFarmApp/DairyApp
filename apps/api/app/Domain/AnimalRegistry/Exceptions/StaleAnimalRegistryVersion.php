<?php

namespace App\Domain\AnimalRegistry\Exceptions;

use RuntimeException;

class StaleAnimalRegistryVersion extends RuntimeException
{
    public function __construct(public readonly int $currentVersion)
    {
        parent::__construct('The record was changed by another request.');
    }
}
