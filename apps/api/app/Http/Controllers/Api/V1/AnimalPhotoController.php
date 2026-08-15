<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\AnimalRegistry\Models\Animal;
use App\Domain\AnimalRegistry\Models\AnimalPhoto;
use App\Http\Controllers\Controller;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class AnimalPhotoController extends Controller
{
    public function __construct(private readonly AuditService $audit) {}

    public function store(Request $request, string $animal): JsonResponse
    {
        $request->validate([
            'photo' => ['required', 'file', 'image', 'mimes:jpeg,jpg,png,webp', 'max:8192'],
        ]);
        $model = $this->animal($request, $animal);
        $file = $request->file('photo');

        $photo = DB::transaction(function () use ($request, $model, $file): AnimalPhoto {
            $locked = Animal::query()->lockForUpdate()->findOrFail($model->id);
            $count = $locked->photos()->count();
            abort_if($count >= 12, 422, 'An animal can have at most 12 photos.');
            $id = (string) Str::uuid7();
            $extension = strtolower($file->guessExtension() ?: 'jpg');
            $path = $file->storeAs(
                "organizations/{$locked->organization_id}/animals/{$locked->id}",
                "{$id}.{$extension}",
                'local',
            );
            $photo = AnimalPhoto::query()->create([
                'id' => $id,
                'organization_id' => $locked->organization_id,
                'animal_id' => $locked->id,
                'storage_path' => $path,
                'original_name' => $file->getClientOriginalName(),
                'mime_type' => $file->getMimeType() ?: 'application/octet-stream',
                'size_bytes' => $file->getSize(),
                'sort_order' => $count + 1,
                'uploaded_by' => $request->user()->id,
            ]);
            $this->audit->record($request, 'animal.photo_uploaded', 'animal', $locked->id, null, [
                'photo_id' => $photo->id,
                'photo_count' => $count + 1,
            ]);

            return $photo;
        });

        return ApiResponse::success($request, [
            'id' => $photo->id,
            'name' => $photo->original_name,
            'sort_order' => $photo->sort_order,
            'photo_requirement_met' => $photo->sort_order >= 4,
        ], 201);
    }

    public function show(Request $request, string $photo): StreamedResponse
    {
        $model = AnimalPhoto::query()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->findOrFail($photo);
        $this->animal($request, $model->animal_id);
        abort_unless(Storage::disk('local')->exists($model->storage_path), 404);

        return Storage::disk('local')->download(
            $model->storage_path,
            $model->original_name,
            ['Content-Type' => $model->mime_type],
        );
    }

    private function animal(Request $request, string $id): Animal
    {
        $farmId = $request->attributes->get('api_session')?->farm_id;
        abort_unless(is_string($farmId) && $farmId !== '', 409, 'An active farm is required.');

        return Animal::query()
            ->where('organization_id', $request->attributes->get('organization_id'))
            ->where('current_farm_id', $farmId)
            ->findOrFail($id);
    }
}
