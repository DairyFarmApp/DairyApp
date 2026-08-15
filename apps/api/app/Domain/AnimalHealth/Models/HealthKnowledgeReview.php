<?php

namespace App\Domain\AnimalHealth\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class HealthKnowledgeReview extends Model
{
    use UsesUuidV7;

    protected $fillable = ['disease_id', 'decision', 'reviewer_notes', 'reviewer_name', 'reviewer_registration', 'reviewed_by'];
}
