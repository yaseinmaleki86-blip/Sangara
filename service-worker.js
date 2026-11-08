/* Sangara v1.2: cache visited catalog for intermittent mobile connectivity. */
const CACHE='sangara-static-v1.2';
const ROOT=new URL('./',self.registration.scope);
const CATALOG=new URL('./',ROOT);
self.addEventListener('install',event=>{
  event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll([ROOT.toString(),CATALOG.toString(),new URL('manifest.webmanifest',ROOT).toString()])).then(()=>self.skipWaiting()).catch(()=>self.skipWaiting()));
});
self.addEventListener('activate',event=>{
  event.waitUntil(caches.keys().then(names=>Promise.all(names.filter(n=>n.startsWith('sangara-static-')&&n!==CACHE).map(n=>caches.delete(n)))).then(()=>self.clients.claim()));
});
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET'||event.request.mode!=='navigate'||new URL(event.request.url).origin!==self.location.origin)return;
  event.respondWith(fetch(event.request).then(response=>{
    if(response.ok){const copy=response.clone();event.waitUntil(caches.open(CACHE).then(cache=>cache.put(event.request,copy)));}
    return response;
  }).catch(async()=>{
    const cache=await caches.open(CACHE);
    return (await cache.match(event.request))||(await cache.match(CATALOG.toString()))||Response.error();
  }));
});
