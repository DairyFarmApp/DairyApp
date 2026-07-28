<?php

namespace App\Domain\AnimalStatuses\Exceptions;

use RuntimeException;

final class AnimalStatusConflict extends RuntimeException
{
    public function __construct(
        public readonly string $errorCode,
        string $message,
        public readonly array $details = [],
    ) {
        parent::__construct($message);
    }
}
