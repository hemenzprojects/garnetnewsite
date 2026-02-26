module.exports = {
  content: [
    "./components/**/*.{js,vue,ts}",
    "./layouts/**/*.vue",
    "./pages/**/*.vue",
    "./plugins/**/*.{js,ts}",
    "./app.vue",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#0F766E', // Teal for academic feel
        secondary: '#059669', // Green
        accent: '#F59E0B', // Amber
      }
    },
  },
  plugins: [],
}