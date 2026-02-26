<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Setting;
use Illuminate\Http\Request;

class SettingController extends Controller
{
    public function index(Request $request)
    {
        $query = Setting::query();

        if ($request->has('group')) {
            $query->where('group', $request->group);
        }

        $settings = $query->get()->mapWithKeys(function ($setting) {
            return [$setting->key => $setting->value];
        });

        return response()->json($settings);
    }

    public function show($key)
    {
        $setting = Setting::where('key', $key)->firstOrFail();

        return response()->json([
            'key' => $setting->key,
            'value' => $setting->value,
        ]);
    }
}
