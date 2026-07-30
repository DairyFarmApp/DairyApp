<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\ProfilePhotoRequest;
use App\Http\Requests\Api\V1\ProfileUpdateRequest;
use App\Models\OrganizationMembership;
use App\Models\User;
use App\Support\ApiResponse;
use App\Support\AuditService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\StreamedResponse;

class ProfileController extends Controller
{
    public function __construct(private readonly AuditService $audit) {}

    public function show(Request $request): JsonResponse
    {
        return ApiResponse::success($request, $this->payload($request->user()));
    }

    public function update(ProfileUpdateRequest $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->safe()->except('current_password');
        if (
            array_key_exists('email', $data) &&
            $data['email'] !== $user->email &&
            ! Hash::check($request->string('current_password')->toString(), $user->password)
        ) {
            return ApiResponse::error(
                $request,
                'INVALID_CURRENT_PASSWORD',
                'Your current password is incorrect.',
                422,
                ['current_password' => [['code' => 'invalid', 'message' => 'Your current password is incorrect.']]],
            );
        }
        $old = $this->payload($user);
        $user->fill($data)->save();
        $this->audit->record(
            $request,
            'profile.updated',
            'user',
            $user->id,
            $old,
            $this->payload($user),
        );

        return ApiResponse::success($request, $this->payload($user));
    }

    public function uploadPhoto(ProfilePhotoRequest $request): JsonResponse
    {
        $user = $request->user();
        $photo = $request->file('photo');
        $extension = strtolower($photo->extension() ?: 'jpg');
        $path = $photo->storeAs(
            'profile-photos',
            Str::uuid7().'.'.$extension,
            'local',
        );
        $oldPath = $user->profile_photo_path;
        $user->forceFill(['profile_photo_path' => $path])->save();
        if ($oldPath) {
            Storage::disk('local')->delete($oldPath);
        }
        $this->audit->record(
            $request,
            'profile.photo_updated',
            'user',
            $user->id,
        );

        return ApiResponse::success($request, $this->payload($user));
    }

    public function deletePhoto(Request $request): JsonResponse
    {
        $user = $request->user();
        if ($user->profile_photo_path) {
            Storage::disk('local')->delete($user->profile_photo_path);
            $user->forceFill(['profile_photo_path' => null])->save();
            $this->audit->record(
                $request,
                'profile.photo_removed',
                'user',
                $user->id,
            );
        }

        return ApiResponse::success($request, $this->payload($user));
    }

    public function photo(Request $request): StreamedResponse
    {
        return $this->photoResponse($request->user());
    }

    public function memberPhoto(Request $request, string $user): StreamedResponse
    {
        $organizationId = $request->attributes->get('organization_id');
        $authorized = OrganizationMembership::query()
            ->where('organization_id', $organizationId)
            ->where('user_id', $user)
            ->where('status', 'active')
            ->exists();
        abort_unless($authorized, 404);

        return $this->photoResponse(User::query()->findOrFail($user));
    }

    private function photoResponse(User $user): StreamedResponse
    {
        abort_unless(
            $user->profile_photo_path &&
            Storage::disk('local')->exists($user->profile_photo_path),
            404,
        );

        return Storage::disk('local')->response(
            $user->profile_photo_path,
            null,
            ['Cache-Control' => 'private, max-age=300'],
        );
    }

    private function payload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone_number' => $user->phone_number,
            'has_profile_photo' => $user->profile_photo_path !== null,
            'updated_at' => $user->updated_at?->toISOString(),
        ];
    }
}
