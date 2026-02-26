<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Service;
use Illuminate\Http\Request;

class ServiceController extends Controller
{
    public function index(Request $request)
    {
        $query = Service::where('is_active', true);

        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        $services = $query->orderBy('order')
            ->select('id', 'name', 'slug', 'description', 'icon', 'featured_image', 'is_featured', 'order')
            ->get();

        return response()->json($services);
    }

    public function show($slug)
    {
        $service = Service::where('slug', $slug)
            ->where('is_active', true)
            ->firstOrFail();

        return response()->json($service);
    }
}
