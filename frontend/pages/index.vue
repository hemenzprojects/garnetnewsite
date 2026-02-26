<template>
  <div>
    <section class="bg-primary text-white py-20">
      <div class="container mx-auto px-4">
        <h1 class="text-5xl font-bold mb-6">Welcome to GARNET</h1>
        <p class="text-xl mb-8">Ghanaian Academic and Research Network</p>
        <p class="text-lg max-w-3xl">
          Connecting Ghana's education sector through high-speed internet,
          educational resources, and innovation opportunities.
        </p>
      </div>
    </section>

    <!-- Services Section - Now Dynamic! -->
    <section class="py-16">
      <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold mb-8">Our Services</h2>

        <div v-if="servicesPending" class="text-center py-8">
          <p class="text-gray-600">Loading services...</p>
        </div>

        <div v-else-if="servicesError" class="text-center py-8">
          <p class="text-red-600">Error loading services: {{ servicesError.message }}</p>
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div v-for="service in services" :key="service.id" class="p-6 border rounded-lg shadow-sm hover:shadow-md transition">
            <h3 class="text-xl font-semibold mb-3">{{ service.name }}</h3>
            <p>{{ service.description }}</p>
          </div>
        </div>
      </div>
    </section>

    <!-- Latest News Section - Also Dynamic! -->
    <section class="py-16 bg-gray-50">
      <div class="container mx-auto px-4">
        <h2 class="text-3xl font-bold mb-8">Latest News</h2>

        <div v-if="newsPending" class="text-center py-8">
          <p class="text-gray-600">Loading news...</p>
        </div>

        <div v-else-if="newsError" class="text-center py-8">
          <p class="text-red-600">Error loading news: {{ newsError.message }}</p>
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div v-for="item in news" :key="item.id" class="bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition">
            <h3 class="text-xl font-semibold mb-3">{{ item.title }}</h3>
            <p class="text-gray-600 mb-4">{{ item.excerpt }}</p>
            <NuxtLink :to="`/news/${item.slug}`" class="text-primary hover:underline">
              Read more →
            </NuxtLink>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
const { fetchServices, fetchNews } = useApi()

// Fetch services from backend
const { data: services, pending: servicesPending, error: servicesError } = await useAsyncData(
  'services',
  () => fetchServices()
)

// Fetch latest news from backend
const { data: newsData, pending: newsPending, error: newsError } = await useAsyncData(
  'news',
  () => fetchNews({ limit: 3 })
)

const news = computed(() => newsData.value?.data || [])

useSeoMeta({
  title: 'GARNET - Ghanaian Academic and Research Network',
  description: 'Connecting Ghana\'s education sector through high-speed internet and innovation'
})
</script>