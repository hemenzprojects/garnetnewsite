# GARNET Website - Laravel + Filament + Nuxt 3

A modern, full-stack web application for the Ghanaian Academic and Research Network (GARNET) built with:
- **Backend**: Laravel 12 + Filament 3 CMS
- **Frontend**: Nuxt 3 + Tailwind CSS
- **Database**: MySQL

## Project Structure

```
garnetnewsite/
├── backend/          # Laravel + Filament CMS
└── frontend/         # Nuxt 3 Frontend
```

## Features

### Backend (Laravel + Filament)
- ✅ Filament Admin Panel for content management
- ✅ RESTful API endpoints
- ✅ Content Models:
  - Pages (static content)
  - News (articles & announcements)
  - Events (conferences & workshops)
  - Members (institutions)
  - Services (GARNET offerings)
  - Settings (site configuration)
- ✅ Image uploads
- ✅ SEO-friendly slugs
- ✅ Published/Draft status

### Frontend (Nuxt 3)
- ✅ Server-side rendering (SSR)
- ✅ Tailwind CSS styling
- ✅ Responsive design
- ✅ API integration
- ✅ SEO optimized

## Installation & Setup

### Prerequisites
- PHP 8.4+
- Composer
- Node.js 18+ (Node 20+ recommended)
- MySQL
- npm or yarn

### Backend Setup

1. **Navigate to backend directory:**
   ```bash
   cd backend
   ```

2. **Configure environment:**
   ```bash
   cp .env.example .env
   ```

   Edit `.env` and configure your database:
   ```
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=garnet
   DB_USERNAME=root
   DB_PASSWORD=your_password
   ```

3. **Install dependencies:**
   ```bash
   composer install
   ```

4. **Run migrations:**
   ```bash
   php artisan migrate
   ```

5. **Create admin user:**
   ```bash
   php artisan make:filament-user
   ```
   Follow the prompts to create your admin account.

6. **Start the server:**
   ```bash
   php artisan serve
   ```

   Backend will run at: http://localhost:8000
   Admin panel: http://localhost:8000/admin

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Configure environment:**
   The `.env` file is already created with:
   ```
   NUXT_PUBLIC_API_BASE=http://localhost:8000/api/v1
   ```

   Update if your backend runs on a different port.

4. **Start development server:**
   ```bash
   npm run dev
   ```

   Frontend will run at: http://localhost:3000

## API Endpoints

All API endpoints are prefixed with `/api/v1`:

### Pages
- `GET /api/v1/pages` - List all published pages
- `GET /api/v1/pages/{slug}` - Get specific page

### News
- `GET /api/v1/news` - List news (supports ?featured=1, ?category={name})
- `GET /api/v1/news/{slug}` - Get specific news item

### Events
- `GET /api/v1/events` - List events (supports ?upcoming=1, ?featured=1)
- `GET /api/v1/events/{slug}` - Get specific event

### Members
- `GET /api/v1/members` - List member institutions (supports ?type={type})
- `GET /api/v1/members/{slug}` - Get specific member

### Services
- `GET /api/v1/services` - List services (supports ?featured=1)
- `GET /api/v1/services/{slug}` - Get specific service

### Settings
- `GET /api/v1/settings` - Get all settings
- `GET /api/v1/settings/{key}` - Get specific setting

## Usage

### Adding Content via Filament Admin

1. **Access the admin panel:**
   - Navigate to http://localhost:8000/admin
   - Login with your admin credentials

2. **Create content:**
   - Use the sidebar menu to access Pages, News, Events, Members, Services, or Settings
   - Click "Create" to add new content
   - Fill in the form fields
   - Set "Is Published" to true to make it visible on the frontend
   - Save

3. **Upload images:**
   - Use the image upload fields in the forms
   - Images are stored in `storage/app/public`

### Frontend Development

The frontend uses Nuxt 3 composables to fetch data from the Laravel API:

```vue
<script setup>
const { fetchNews } = useApi()
const { data: news } = await useAsyncData('news', () => fetchNews())
</script>
```

## File Structure

### Backend Key Files
```
backend/
├── app/
│   ├── Models/              # Eloquent models
│   ├── Http/Controllers/Api/ # API controllers
│   └── Filament/Resources/  # Filament admin resources
├── database/migrations/     # Database migrations
└── routes/api.php          # API routes
```

### Frontend Key Files
```
frontend/
├── pages/                  # Nuxt pages (routes)
├── components/            # Vue components
├── composables/           # Composable functions (useApi)
├── layouts/               # Layout components
├── assets/css/            # CSS files
└── nuxt.config.ts         # Nuxt configuration
```

## Development Workflow

1. **Backend-First Approach:**
   - Create models and migrations in Laravel
   - Add Filament resources for admin management
   - Create API endpoints
   - Test API with tools like Postman

2. **Frontend Integration:**
   - Create pages in Nuxt
   - Use `useApi` composable to fetch data
   - Build components for displaying content
   - Style with Tailwind CSS

## Production Deployment

### Backend
1. Set up production database
2. Configure `.env` for production
3. Run `composer install --optimize-autoloader --no-dev`
4. Run `php artisan migrate`
5. Run `php artisan optimize`
6. Set up proper web server (Nginx/Apache)

### Frontend
1. Build the production app: `npm run build`
2. Or generate static site: `npm run generate`
3. Deploy to hosting (Vercel, Netlify, or custom server)

## Important Notes

- **Node Version**: This project uses Node 18.20.8. Some packages recommend Node 20+, but the current setup works with Node 18.
- **CORS**: If you encounter CORS issues, configure CORS middleware in Laravel's bootstrap/app.php
- **Images**: Make sure to run `php artisan storage:link` to create the symbolic link for public storage
- **API Base URL**: Update `NUXT_PUBLIC_API_BASE` in frontend/.env for production deployment

## Next Steps

1. **Create Admin User** (if not done):
   ```bash
   cd backend
   php artisan make:filament-user
   ```

2. **Add Sample Content**:
   - Login to admin panel
   - Create some pages, news items, events, etc.

3. **Customize Design**:
   - Edit Tailwind colors in `frontend/tailwind.config.js`
   - Create Vue components in `frontend/components/`
   - Add more pages in `frontend/pages/`

4. **Add More Features**:
   - User authentication
   - Search functionality
   - Newsletter subscription
   - Contact forms
   - Multi-language support

## Support

For Laravel documentation: https://laravel.com/docs
For Filament documentation: https://filamentphp.com/docs
For Nuxt documentation: https://nuxt.com/docs
For Tailwind CSS: https://tailwindcss.com/docs

## License

This project is built for GARNET (Ghanaian Academic and Research Network).