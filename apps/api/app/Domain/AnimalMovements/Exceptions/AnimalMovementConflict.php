<?php

namespace App\Domain\AnimalMovements\Exceptions;

use RuntimeException;

class AnimalMovementConflict extends RuntimeException
{
    public function __construct(
        public readonly string $errorCode,
        string $message,
        public readonly array $details = [],
    ) {
        parent::__construct($message);
    }
}
