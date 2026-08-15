<?php
namespace App\Http\Requests\Api\V1;
use Illuminate\Foundation\Http\FormRequest; use Illuminate\Validation\Rule;
class HealthAiAskRequest extends FormRequest { public function authorize():bool{return true;} public function rules():array{return['question'=>['required','string','min:5','max:1000'],'species'=>['required',Rule::in(['cattle','buffalo','goat'])],'symptom_codes'=>['sometimes','array','max:20'],'symptom_codes.*'=>['string','exists:health_symptoms,code','distinct'],'language'=>['sometimes',Rule::in(['english','roman_urdu','both'])]];} }
