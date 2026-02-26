<?php

namespace Database\Seeders;

use App\Models\Service;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    public function run(): void
    {
        Service::create([
            'name' => 'High-Speed Internet',
            'slug' => 'high-speed-internet',
            'description' => 'Reliable, high-bandwidth connectivity for research and education institutions across Ghana. Our fiber-optic network ensures consistent performance for academic activities.',
            'is_active' => true,
        ]);

        Service::create([
            'name' => 'Eduroam',
            'slug' => 'eduroam',
            'description' => 'Seamless educational roaming service that allows students and faculty to access wireless networks at participating institutions worldwide using their home institution credentials.',
            'is_active' => true,
        ]);

        Service::create([
            'name' => 'Video Conferencing',
            'slug' => 'video-conferencing',
            'description' => 'Advanced video conferencing infrastructure supporting virtual collaboration, online learning, and international research partnerships with HD quality and reliable uptime.',
            'is_active' => true,
        ]);

        Service::create([
            'name' => 'Cloud Services',
            'slug' => 'cloud-services',
            'description' => 'Secure cloud storage and computing resources for academic institutions, enabling collaborative research, data sharing, and backup solutions.',
            'is_active' => true,
        ]);

        Service::create([
            'name' => 'Cybersecurity',
            'slug' => 'cybersecurity',
            'description' => 'Comprehensive cybersecurity solutions including threat monitoring, incident response, and security training to protect institutional networks and data.',
            'is_active' => true,
        ]);
    }
}
