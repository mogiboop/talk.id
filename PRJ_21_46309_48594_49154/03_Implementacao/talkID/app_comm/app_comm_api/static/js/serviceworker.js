/*
var staticCacheName = 'djangopwa-talkID';
 
self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(staticCacheName).then(function(cache) {
      return cache.addAll([
        //'',
        //'/',
        //'/manage_accounts/',
        //'/login/',
        //'/register_patient/',
        //'/logout/',
        //'/subscribe/',
        //'/unsubscribe/',
        '/static/css/styles.css',
        '/static/images/logo_website.png',
        '/static/images/logo_website-48x48.png',
        '/static/images/logo_website-72x72.png',
        '/static/images/logo_website-96x96.png',
        '/static/images/logo_website-144x144.png',
        '/static/images/logo_website-192x192.png',
        '/static/images/logo_website-120x120.png',
        '/static/images/logo_website-152x152.png',
        '/static/images/logo_website-167x167.png',
        '/static/images/logo_website-180x180.png',
        '/static/images/logo_website-1024x1024.png',
        '/static/images/favicon.ico',
        '/static/images/Muscles_front_and_back.svg',
        '/static/images/4.jpeg',
        '/static/js/index.js',
        '/static/js/manage_acc.js',
        '/static/js/user_solutions.js',
        '/static/sounds/mixkit-bell-notification-933.wav',
        '/static/webpush/webpush_serviceworker.js',
        '/static/webpush/webpush.js',
      ]);
    })
  );
});
 
self.addEventListener('fetch', function(event) {
  var requestUrl = new URL(event.request.url);
    if (requestUrl.origin === location.origin) {
      if ((requestUrl.pathname === '/')) {
        //event.respondWith(caches.match(''));
        return;
      }
    }
    event.respondWith(
      caches.match(event.request).then(function(response) {
        return response || fetch(event.request);
      })
    );
});
*/


// This is an empty cache setup for online-only functionality
const CACHE_NAME = 'djangopwa-talkID';

self.addEventListener('install', (event) => {
  // Skip waiting to activate immediately
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  // Clean up old caches
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request).catch((error) => {
      console.error('Fetch failed:', error);
      // Display an offline message or redirect to an offline page
      return new Response('You are offline. Please check your internet connection.', {
        headers: { 'Content-Type': 'text/plain' }
      });
    })
  );
});

