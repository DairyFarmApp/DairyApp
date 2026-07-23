<?php

namespace App\Domain\AnimalMovements\Exceptions;

use RuntimeException;

class StaleAnimalMovementVersion extends RuntimeException
{
    public function __construct(public readonly int $currentVersion)
    {
        parent::__construct('The animal movement was changed by another request.');
    }
}
