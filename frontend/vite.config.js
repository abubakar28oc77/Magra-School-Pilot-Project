import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [react(), VitePWA({
    registerType: 'autoUpdate',
    includeAssets: ['school-logo.png', 'school-building.jpg'],
    manifest: {
      name: 'মগড়া পালস্‌ ইউনিয়ন উচ্চ বিদ্যালয়',
      short_name: 'মগড়া স্কুল ERP',
      description: 'মগড়া পালস্‌ ইউনিয়ন উচ্চ বিদ্যালয়ের School Management ও Digital Learning Platform',
      lang: 'bn-BD',
      start_url: '/?source=pwa',
      display: 'standalone',
      orientation: 'portrait-primary',
      theme_color: '#176b4b',
      background_color: '#f4f8f5',
      icons: [
        { src: '/school-logo.png', sizes: '192x192', type: 'image/png', purpose: 'any maskable' },
        { src: '/school-logo.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
      ],
      shortcuts: [
        { name: 'Login', short_name: 'Login', url: '/login', icons: [{ src: '/school-logo.png', sizes: '192x192' }] },
        { name: 'Notice', short_name: 'Notice', url: '/#notice', icons: [{ src: '/school-logo.png', sizes: '192x192' }] }
      ],
      categories: ['education', 'productivity']
    },
    workbox: { navigateFallback: '/index.html', cleanupOutdatedCaches: true },
    devOptions: { enabled: false }
  })]
});
