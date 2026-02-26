<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Page;
use Illuminate\Http\Request;

class PageController extends Controller
{
    public function index()
    {
        $pages = Page::where('is_published', true)
            ->orderBy('order')
            ->select('id', 'title', 'slug', 'excerpt', 'featured_image', 'order')
            ->get();

        return response()->json($pages);
    }

    public function show($slug)
    {
        $page = Page::where('slug', $slug)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json($page);
    }
}
