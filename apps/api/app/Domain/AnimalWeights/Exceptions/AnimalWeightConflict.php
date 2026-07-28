<?php

namespace App\Domain\AnimalWeights\Exceptions;

use RuntimeException;

final class AnimalWeightConflict extends RuntimeException
{
    public function __construct(
        public readonly string $errorCode,
        string $message,
        public readonly array $details = [],
    ) {
        parent::__construct($message);
    }
}
