<?php

namespace App\Models;

use App\Models\Concerns\UsesUuidV7;
use Illuminate\Database\Eloquent\Model;

class Permission extends Model
{
    use UsesUuidV7;

    protected $fillable = ['name', 'description'];
}
