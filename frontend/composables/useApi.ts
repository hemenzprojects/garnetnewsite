export const useApi = () => {
  const config = useRuntimeConfig()
  const apiBase = config.public.apiBase

  const fetchPages = async () => {
    return await $fetch(`${apiBase}/pages`)
  }

  const fetchPage = async (slug: string) => {
    return await $fetch(`${apiBase}/pages/${slug}`)
  }

  const fetchNews = async (params = {}) => {
    return await $fetch(`${apiBase}/news`, { params })
  }

  const fetchNewsItem = async (slug: string) => {
    return await $fetch(`${apiBase}/news/${slug}`)
  }

  const fetchEvents = async (params = {}) => {
    return await $fetch(`${apiBase}/events`, { params })
  }

  const fetchEvent = async (slug: string) => {
    return await $fetch(`${apiBase}/events/${slug}`)
  }

  const fetchMembers = async (params = {}) => {
    return await $fetch(`${apiBase}/members`, { params })
  }

  const fetchMember = async (slug: string) => {
    return await $fetch(`${apiBase}/members/${slug}`)
  }

  const fetchServices = async (params = {}) => {
    return await $fetch(`${apiBase}/services`, { params })
  }

  const fetchService = async (slug: string) => {
    return await $fetch(`${apiBase}/services/${slug}`)
  }

  const fetchSettings = async () => {
    return await $fetch(`${apiBase}/settings`)
  }

  return {
    fetchPages,
    fetchPage,
    fetchNews,
    fetchNewsItem,
    fetchEvents,
    fetchEvent,
    fetchMembers,
    fetchMember,
    fetchServices,
    fetchService,
    fetchSettings,
  }
}