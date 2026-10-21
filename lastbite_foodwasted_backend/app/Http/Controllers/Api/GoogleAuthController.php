<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class GoogleAuthController extends Controller
{
    public function login(Request $request)
    {
        $request->validate(['id_token' => 'required|string']);

        $res = Http::get('https://oauth2.googleapis.com/tokeninfo', [
            'id_token' => $request->id_token,
        ]);

        if (!$res->ok()
            || ($res['aud'] ?? null) !== config('services.google.client_id')
            || ($res['email_verified'] ?? 'false') !== 'true') {
            return response()->json(['message' => 'Token Google tidak valid'], 401);
        }

        $user = User::firstOrCreate(
            ['email' => $res['email']],
            [
                'name' => $res['name'] ?? $res['email'],
                'role' => 'pelanggan',
            ]
        );

        return response()->json([
            'token' => $user->createToken('google')->plainTextToken,
            'user'  => $user,
        ]);
    }
}