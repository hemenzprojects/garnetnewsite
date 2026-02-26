<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Http\Request;

class NewsController extends Controller
{
    public function index(Request $request)
    {
        $query = News::where('is_published', true);

        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        if ($request->has('category')) {
            $query->where('category', $request->category);
        }

        $news = $query->orderBy('published_at', 'desc')
            ->select('id', 'title', 'slug', 'excerpt', 'featured_image', 'category', 'published_at', 'is_featured')
            ->paginate($request->get('per_page', 10));

        return response()->json($news);
    }

    public function show($slug)
    {
        $news = News::where('slug', $slug)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json($news);
    }
}
