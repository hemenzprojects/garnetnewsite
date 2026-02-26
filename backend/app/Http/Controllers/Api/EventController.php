<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $query = Event::where('is_published', true);

        if ($request->has('upcoming')) {
            $query->where('start_date', '>=', now());
        }

        if ($request->has('featured')) {
            $query->where('is_featured', true);
        }

        $events = $query->orderBy('start_date', 'asc')
            ->select('id', 'title', 'slug', 'description', 'location', 'venue', 'featured_image', 'start_date', 'end_date', 'registration_link', 'is_featured')
            ->paginate($request->get('per_page', 10));

        return response()->json($events);
    }

    public function show($slug)
    {
        $event = Event::where('slug', $slug)
            ->where('is_published', true)
            ->firstOrFail();

        return response()->json($event);
    }
}
