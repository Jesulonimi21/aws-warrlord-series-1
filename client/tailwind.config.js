/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: "hsl(220, 90%, 55%)",
        secondary: "hsl(210, 40%, 65%)", /* Soft Blue-Gray */
        accent: "hsl(30, 90%, 55%)"
      }
    },

  },
  plugins: [],
}