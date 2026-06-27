const CACHE = 'eldistrito-v3';

const PRECACHE = [
  '/',
  '/index.html',
];

// ── Install: precachear shell ──
self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE)
      .then(c => c.addAll(PRECACHE))
      .then(() => self.skipWaiting())
  );
});

// ── Activate: limpiar caches viejos ──
self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// ── Fetch strategy ──
self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);

  // API calls: network only, nunca cachear
  if (url.pathname.startsWith('/api/')) return;

  // USGS, Supabase, Leaflet tiles: network only (datos en tiempo real)
  if (
    url.hostname.includes('usgs.gov') ||
    url.hostname.includes('supabase.co') ||
    url.hostname.includes('basemaps.cartocdn.com') ||
    url.hostname.includes('tile.openstreetmap.org')
  ) return;

  // Todo lo demás: cache-first, fallback network, guarda en cache
  e.respondWith(
    caches.match(e.request).then(cached => {
      if (cached) return cached;

      return fetch(e.request).then(res => {
        // Solo cachear respuestas válidas
        if (!res || res.status !== 200 || res.type === 'opaque') return res;

        const clone = res.clone();
        caches.open(CACHE).then(c => c.put(e.request, clone));
        return res;
      }).catch(() => {
        // Offline fallback: siempre devolver el shell
        if (e.request.mode === 'navigate') {
          return caches.match('/index.html');
        }
      });
    })
  );
});