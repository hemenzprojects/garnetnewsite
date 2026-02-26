<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Member;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    public function index(Request $request)
    {
        $query = Member::where('is_active', true);

        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        $members = $query->orderBy('order')
            ->select('id', 'name', 'slug', 'type', 'description', 'logo', 'website', 'location', 'order')
            ->get();

        return response()->json($members);
    }

    public function show($slug)
    {
        $member = Member::where('slug', $slug)
            ->where('is_active', true)
            ->firstOrFail();

        return response()->json($member);
    }
}
