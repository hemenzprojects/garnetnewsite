<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    protected $fillable = [
        'title',
        'slug',
        'description',
        'location',
        'venue',
        'featured_image',
        'start_date',
        'end_date',
        'registration_link',
        'is_published',
        'is_featured',
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'is_published' => 'boolean',
        'is_featured' => 'boolean',
    ];
}
