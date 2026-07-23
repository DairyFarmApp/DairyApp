<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class FarmRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $presence = $this->isMethod('post') ? 'required' : 'sometimes';

        return ['id' => ['sometimes', 'uuid'], 'name' => [$presence, 'string', 'max:160'], 'code' => ['sometimes', 'string', 'max:40'], 'timezone' => [$presence, 'timezone']];
    }
}
