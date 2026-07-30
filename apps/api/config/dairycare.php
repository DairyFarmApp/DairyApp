<?php

return [
    'seed_password' => env('DAIRYCARE_SEED_PASSWORD'),
    'auth' => [
        'access_ttl_minutes' => (int) env('AUTH_ACCESS_TTL_MINUTES', 15),
        'renewal_ttl_days' => (int) env('AUTH_RENEWAL_TTL_DAYS', 30),
        'failure_window_minutes' => (int) env('AUTH_FAILURE_WINDOW_MINUTES', 15),
        'lock_threshold' => (int) env('AUTH_LOCK_THRESHOLD', 5),
        'lock_minutes' => (int) env('AUTH_LOCK_MINUTES', 5),
        'maximum_family_accounts' => (int) env('AUTH_MAXIMUM_FAMILY_ACCOUNTS', 25),
    ],
];
